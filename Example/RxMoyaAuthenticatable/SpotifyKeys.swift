import Keys

final class SpotifyKeys {
  static let keys = RxMoyaAuthenticatable_ExampleKeys()

  static let clientId: String = {
    return SpotifyKeys.keys.spotifyClientId
  }()

  static let clientSecret: String = {
    return SpotifyKeys.keys.spotifyClientSecret
  }()

  static let redirectUri: String = {
    return SpotifyKeys.keys.spotifyCallbackUri
  }()

  static let customUrlScheme: String = {
    return SpotifyKeys.keys.spotifyCallbackUrlScheme
  }()
}
