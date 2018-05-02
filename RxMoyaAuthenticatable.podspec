Pod::Spec.new do |s|
  s.name             = 'RxMoyaAuthenticatable'
  s.version          = '0.1.0'
  s.summary          = 'Attach persisted authentication to a request header and refresh authentication if needed.'
  s.homepage         = 'https://github.com/keitaoouchi/RxMoyaAuthenticatable'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'keita.oouchi' => 'keita.oouchi@gmail.com' }
  s.source           = { :git => 'https://github.com/keitaoouchi/RxMoyaAuthenticatable.git', :tag => s.version.to_s }
  s.ios.deployment_target = '11.0'
  s.source_files = 'RxMoyaAuthenticatable/Classes/**/*'
  s.dependency 'Moya/RxSwift', '~> 11.0'
end
