#
# Be sure to run `pod lib lint AnimatedLaunchScreenKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'AnimatedLaunchScreenKit'
  s.version          = '0.1.0'
  s.summary          = 'A reusable animated launch screen engine for iOS.'
  s.description      = <<-DESC
HPGLaunchScreenKit provides a configurable, animation-driven launch screen
experience for iOS apps using slot-style visuals, custom logos, and timing control.
  DESC

  s.homepage         = 'https://github.com/owersbrett/AnimatedLaunchScreenKit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'owersbrett' => 'owersbrett@gmail.com' }
  s.source           = { :git => 'https://github.com/owersbrett/AnimatedLaunchScreenKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '11.0'

  s.source_files = 'AnimatedLaunchScreenKit/Classes/**/*'
  
  s.resource_bundles = {
    'AnimatedLaunchScreenKitAssets' => ['AnimatedLaunchScreenKit/Assets/*']
  }


  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
