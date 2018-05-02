import UIKit
import Moya
import RxSwift
import RxMoyaAuthenticatable
import SafariServices
import Keys

final class SpotifyViewController: UIViewController {

  private var session: SFAuthenticationSession?
  private let disposeBag: DisposeBag = DisposeBag()
}

private extension SpotifyViewController {

  @IBAction func onTapSignin(sender: UIButton) {
    let oauthService = SpotifyOauthService(
      redirectUri: SpotifyKeys.redirectUri,
      clientId: SpotifyKeys.clientId
    )

    let session = SFAuthenticationSession(
      url: oauthService.url,
      callbackURLScheme: SpotifyKeys.customUrlScheme) { [weak self] url, error in
        guard let _self = self else { return }

        guard let url = url, let code = oauthService.process(url: url) else { return }

        SpotifyAuthentication
          .apply(code: code, redirectUri: oauthService.redirectUri)
          .subscribe(
            onSuccess: { authentication in
              print(authentication)
            },
            onError: { error in
              print(error)
            }
          ).disposed(by: _self.disposeBag)
    }
    session.start()

    self.session = session
  }

  @IBAction func onTapRefresh(sender: UIButton) {
    guard let authentication = SpotifyAuthentication.find() else {
      return
    }

    authentication.refresh().subscribe(
      onSuccess: { authentication in
        print(authentication)
      },
      onError: { error in
        print(error)
      }
    )
  }

  @IBAction func onTapDemo(sender: UIButton) {
    guard let authentication = SpotifyAuthentication.find() else {
      return
    }

    for _ in 1..<10 {
      SpotifyAPI.sharedProvider.request(.me) { result in
        print(result)
      }
    }
  }
}
