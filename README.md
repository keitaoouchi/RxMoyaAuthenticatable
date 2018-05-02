# RxMoyaAuthenticatable

[![CI Status](https://img.shields.io/travis/keita.ouchi/RxMoyaAuthenticatable.svg?style=flat)](https://travis-ci.org/keita.ouchi/RxMoyaAuthenticatable)
[![Version](https://img.shields.io/cocoapods/v/RxMoyaAuthenticatable.svg?style=flat)](https://cocoapods.org/pods/RxMoyaAuthenticatable)
[![License](https://img.shields.io/cocoapods/l/RxMoyaAuthenticatable.svg?style=flat)](https://cocoapods.org/pods/RxMoyaAuthenticatable)
[![Platform](https://img.shields.io/cocoapods/p/RxMoyaAuthenticatable.svg?style=flat)](https://cocoapods.org/pods/RxMoyaAuthenticatable)

Make your API token refreshable with RxMoyaAuthenticatable!

RxMoyaAuthenticatable provides standard requestClosure which refresh accessToken automatically on your needs!

This requestClosure intercept your requests, execute followings:

- suspend all requests in a serial dispatch queue,
- find persisted authentication,
- refresh found authentication if needed,
- resume other requests in a serial queue.

## How to use

Adapt **RefreshableAuthentication** protocol to your `Authentication` entity:

```swift
public protocol RefreshableAuthentication {
  var isRefreshNeeded: Bool { get }
  var accessToken: String { get }
  func refresh() -> Single<Self>

  static func find() -> Self?
}
```

For example:

```swift
import RxSwift
import Moya
import RxMoyaAuthenticatable

struct SpotifyAuthentication: RefreshableAuthentication, Decodable {

  let accessToken: String
  var refreshToken: String!
  var createdAt: Date = Date()
  let expiresIn: Int

  var isRefreshNeeded: Bool {
    let threshold = TimeInterval(self.expiresIn / 2)
    let result = self.expiresAt < Date().addingTimeInterval(threshold)
    return result
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
}

```
(See example implementation using Spotify's API [here](https://github.com/keitaoouchi/RxMoyaAuthenticatable/blob/master/Example/RxMoyaAuthenticatable/SpotifyAuthentication.swift))

Using this and your API, accessToken will automatically refresh when `isRefreshNeeded` returns True:

```swift
let provider = MoyaProvider<SpotifyAPI>(
  requestClosure: RxMoyaAuthenticatable<SpotifyAPI, SpotifyAuthentication>().requestClosure
)
```

## Example

To run the example project, clone the repo, and see [Example/Readme.md](https://github.com/keitaoouchi/RxMoyaAuthenticatable/blob/master/Example/README.md).
In this example, we implemented Spotify's [Authorization Code Flow](https://beta.developer.spotify.com/documentation/general/guides/authorization-guide/).

## Requirements

| Target            | Version  |
|-------------------|----------|
| iOS               |  => 11.0 |
| Swift             |  => 4.0  |
| Moya/RxSwift      |  => 11.0 |

## Installation

RxMoyaAuthenticatable is available through [CocoaPods](https://cocoapods.org).
To installit, simply add the following line to your Podfile:

```ruby
pod 'RxMoyaAuthenticatable'
```

## Author

keitaoouchi, keita.oouchi@gmail.com

## License

RxMoyaAuthenticatable is available under the MIT license. See the LICENSE file for more info.
