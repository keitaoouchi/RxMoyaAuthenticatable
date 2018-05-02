import Moya
import RxMoyaAuthenticatable

enum SpotifyAuthAPI {
  case oauth(code: String, redirectUri: String)
  case refreshToken(refreshToken: String)
}

extension SpotifyAuthAPI {
  static var sharedProvider: MoyaProvider<SpotifyAuthAPI> = MoyaProvider<SpotifyAuthAPI>(
    plugins: [
      SpotifyBasicAuthPlugin(clientId: SpotifyKeys.clientId,
                             clientSecret: SpotifyKeys.clientSecret)
    ]
  )
}

extension SpotifyAuthAPI: TargetType {

  var baseURL: URL {
    return URL(string: "https://accounts.spotify.com/")!
  }

  var path: String {
    return "api/token"
  }

  var method: Moya.Method {
    return .post
  }

  var task: Moya.Task {
    switch self {
    case .oauth(let code, let redirectUri):
      return .requestParameters(
        parameters: [
          "code": code,
          "redirect_uri": redirectUri,
          "grant_type": "authorization_code"
        ],
        encoding: URLEncoding.httpBody
      )
    case .refreshToken(let refreshToken):
      return .requestParameters(
        parameters: [
          "refresh_token": refreshToken,
          "grant_type": "refresh_token"
        ],
        encoding: URLEncoding.httpBody
      )
    }
  }

  var headers: [String: String]? {
    switch self {
    case .oauth, .refreshToken:
      // Authorization header is set in SpotifyBasicAuthPlugin
      return nil
    }
  }

  var sampleData: Data {
    return Data()
  }
}

struct SpotifyBasicAuthPlugin: PluginType {

  let clientId: String
  let clientSecret: String

  func prepare(_ request: URLRequest, target: TargetType) -> URLRequest {

    var request = request
    let basic = "\(clientId):\(clientSecret)".data(using: .utf8)!.base64EncodedString()
    request.addValue("Basic \(basic)", forHTTPHeaderField: "Authorization")
    return request
  }

}

