### Getting started

Before start this, you should have Spotify's Developer Account.
You need,

- Client ID
- Client Secret
- CallbackURL
  + In this example, we use SFAuthenticationSession. Please set this `Custom URL Scheme` in your favor.

Fill clientId and clientSecret of your own in `.env`, then `bundle install` and `bundle exec pod install`.
This will use [cocoapods-keys](https://github.com/orta/cocoapods-keys) to save your secrets to Keychain,
App will do demo with their keys.

```.env
spotifyClientId = ""
spotifyClientSecret = ""
spotifyCallbackUri = "rxmoyaauthenticatable://signin"
spotifyCallbackUrlScheme = "rxmoyaauthenticatable"
```

```bash
bundle install --path vendor/path
bundle exec pod install
open RxMoyaAuthenticatable.xcworkspace
```
