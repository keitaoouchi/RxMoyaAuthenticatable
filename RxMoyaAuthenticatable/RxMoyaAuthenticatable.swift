import Foundation
import Moya
import RxMoya
import RxSwift

// MARK: - Protocol

public protocol RefreshableAuthentication {
  var isRefreshNeeded: Bool { get }
  var accessToken: String { get }
  func refresh() -> Single<Self>

  static func find() -> Self?
}

// MARK: - Error

public enum RXMoyaAuthenticatableError: Error {
  case requestError
}

// MARK: - RxMoyaAuthenticatable

/// Provides requestClosure which refresh accessToken automatically if needed.
public struct RxMoyaAuthenticatable<API: TargetType, Authenticatable: RefreshableAuthentication>: PluginType {

  public typealias OnComplete = MoyaProvider<API>.RequestResultClosure

  private let requestQueue = DispatchQueue(label: "com.keita.oouchi.requestQueue")
  private let disposeBag = DisposeBag()

  public init() {}

  /// Before sending request, execute **finding persisted authentication**, **refreshing found authentication if needed**, **resume other requests** in a serial queue.
  public func requestClosure(endpoint: Endpoint, done: @escaping OnComplete) {
    requestQueue.async {
      self.suspend()
      self.authorizeRequestInSerialQueue(endPoint: endpoint, done: done)
    }
  }
}

private extension RxMoyaAuthenticatable {

  /// find persisted authentication, and if found authentication needs refreshing, execute refreshing, then resume queued other requests.
  func authorizeRequestInSerialQueue(endPoint: Endpoint, done: @escaping OnComplete) {

    guard let request = try? endPoint.urlRequest() else {
      done(.failure(MoyaError.underlying(RXMoyaAuthenticatableError.requestError, nil)))
      self.resume()
      return
    }

    if let authentication = Authenticatable.find() {
      if authentication.isRefreshNeeded {
        authentication
          .refresh()
          .subscribe(
            onSuccess: { refreshedAuthentication in
              done(.success(self.makeAuthorizedRequest(from: request)))
              self.resume()
            },
            onError: { error in
              done(.failure(MoyaError.underlying(error, nil)))
            }
          ).disposed(by: self.disposeBag)
      } else {
        done(.success(self.makeAuthorizedRequest(from: request)))
        self.resume()
      }
    } else {
      done(.success(request))
      self.resume()
    }
  }

  func makeAuthorizedRequest(from originalRequest: URLRequest) -> URLRequest {
    var request = originalRequest
    if let authentication = Authenticatable.find() {
      request.addValue(
        "Bearer \(authentication.accessToken)",
        forHTTPHeaderField: "Authorization"
      )
    }
    return request
  }

  func suspend() {
    requestQueue.suspend()
  }

  func resume() {
    requestQueue.resume()
  }
}

