import UIKit

struct SpotifyOauthService {

  let redirectUri: String
  let clientId: String
  let state: String = UUID().uuidString.replacingOccurrences(of: "-", with: "")

  var url: URL {
    let str = [
      "https://accounts.spotify.com/authorize?",
      "client_id=\(clientId)",
      "&redirect_uri=\(redirectUri)",
      "&response_type=code",
      "&state=\(state)"
    ].joined()
    return URL(string: str)!
  }

  func process(url: URL) -> String? {
    var items = [String: String]()

    url
      .query?
      .components(separatedBy: "&")
      .map { $0.components(separatedBy: "=") }
      .forEach { keyValue in
        if let key = keyValue.first, let value = keyValue.last {
          items[key] = value
        }
    }

    guard let callbackState = items["state"], callbackState == state else {
      return nil
    }

    if let error = items["error"] {
      return nil
    }

    if let code = items["code"] {
      return code
    }

    return nil
  }

}
