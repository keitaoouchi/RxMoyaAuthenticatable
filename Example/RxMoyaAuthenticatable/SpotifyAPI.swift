import Moya
import RxMoyaAuthenticatable

enum SpotifyAPI {
  case me
}

extension SpotifyAPI {
  static var sharedProvider: MoyaProvider<SpotifyAPI> = {
    let authenticatable = RxMoyaAuthenticatable<SpotifyAPI, SpotifyAuthentication>()
    return MoyaProvider<SpotifyAPI>(
      requestClosure: authenticatable.requestClosure
    )
  }()
}

extension SpotifyAPI: TargetType {

  var baseURL: URL {
    return URL(string: "https://api.spotify.com/")!
  }

  var path: String {
    return "v1/me"
  }

  var method: Moya.Method {
    return .get
  }

  var task: Moya.Task {
    switch self {
    case .me:
      return .requestParameters(parameters: [:], encoding: URLEncoding.queryString)
    }
  }

  var headers: [String: String]? {
    switch self {
    case .me:
      return nil
    }
  }

  var sampleData: Data {
    return Data()
  }
}
