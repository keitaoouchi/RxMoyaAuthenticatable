import RxSwift
import Moya
import RxMoyaAuthenticatable
import KeychainAccess

struct SpotifyAuthentication: RefreshableAuthentication, Decodable {

  let accessToken: String
  var refreshToken: String!
  var createdAt: Date = Date()
  let expiresIn: Int

  var isRefreshNeeded: Bool {
    // Always refresh for demo
    return true

    // Sample implementation
    /*
    let threshold = TimeInterval(self.expiresIn / 2)
    let result = self.expiresAt < Date().addingTimeInterval(threshold)
    return result
    */
  }

  static func find() -> SpotifyAuthentication? {
    return SpotifyAuthenticationStore.find()
  }

  func refresh() -> Single<SpotifyAuthentication> {
    let refreshToken = self.refreshToken
    return
      SpotifyAuthAPI
        .sharedProvider
        .rx
        .request(.refreshToken(refreshToken: self.refreshToken))
        .map { response -> SpotifyAuthentication in
          if var authentication = try? JSONDecoder().decode(SpotifyAuthentication.self, from: response.data) {
            authentication.refreshToken = refreshToken
            return authentication
          } else {
            throw SpotifyAPIError.mappingError
          }
        }.do(
          onSuccess: { authentication in
            SpotifyAuthenticationStore.save(authentication: authentication)
          },
          onError: { error in
            print(error)
          }
        )
  }
}

extension SpotifyAuthentication {

  enum CodingKeys: String, CodingKey {
    case accessToken = "access_token"
    case refreshToken = "refresh_token"
    case expiresIn = "expires_in"
  }

  var expiresAt: Date {
    return createdAt.addingTimeInterval(TimeInterval(expiresIn))
  }

  static func apply(code: String, redirectUri: String) -> Single<SpotifyAuthentication> {
    return
      SpotifyAuthAPI
        .sharedProvider
        .rx
        .request(.oauth(code: code, redirectUri: redirectUri))
        .map { response -> SpotifyAuthentication in
          if let authentication = try? JSONDecoder().decode(SpotifyAuthentication.self, from: response.data) {
            return authentication
          } else {
            throw SpotifyAPIError.mappingError
          }
        }.do(
          onSuccess: { authentication in
            SpotifyAuthenticationStore.save(authentication: authentication)
          },
          onError: { error in
            print(error)
          }
        )
  }

}

// MARK: - Private Persistent Layer

private struct SpotifyAuthenticationStore {

  static func save(authentication: SpotifyAuthentication) {
    keychain["access_token"] = authentication.accessToken
    keychain["created_at"] = authentication.createdAt.timeIntervalSince1970.description
    keychain["expires_in"] = authentication.expiresIn.description
    keychain["refresh_token"] = authentication.refreshToken
  }

  static func find() -> SpotifyAuthentication? {
    let keychain = SpotifyAuthenticationStore.keychain
    let accessToken = keychain["access_token"]
    let refreshToken = keychain["refresh_token"]
    let createdAt = keychain["created_at"].flatMap { description in
      return Double(description).flatMap { seconds in
        Date(timeIntervalSince1970: seconds)
      }
    }
    let expiresIn = keychain["expires_in"].flatMap { description in
      return Int(description)
    }

    if let accessToken = accessToken,
      let refreshToken = refreshToken,
      let createdAt = createdAt,
      let expiresIn = expiresIn {
      return SpotifyAuthentication(
        accessToken: accessToken,
        refreshToken: refreshToken,
        createdAt: createdAt,
        expiresIn: expiresIn
      )
    }
    return nil
  }

  static var keychain: Keychain = {
    let keychain = Keychain(server: serverName, protocolType: .https)
      .label(serverName)
      .synchronizable(false)
      .accessibility(Accessibility.afterFirstUnlockThisDeviceOnly)
    return keychain
  }()

  private static var serverName: String {
    return "https://rxmoyaauthenticatable.com"
  }
}
