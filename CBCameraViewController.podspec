#
# Be sure to run `pod lib lint CBCameraViewController.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'CBCameraViewController'
  s.version          = '0.0.1'
  s.summary          = 'This pod helps you to create a camera view controller that takes photos and videos'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  This CBCameraViewController helps you to create a view controlelr that has a built-in camera function in it. You can call its delegate to trigger certain actions when the camera button is pressed and when the user captures a photo or while recording.
                       DESC

  s.homepage         = 'https://github.com/cathy810218/CBCameraViewController'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Cathy Oun' => 'cathy810218@gmail.com' }
  s.source           = { :git => 'https://github.com/cathy810218/CBCameraViewController.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'

  s.source_files = 'CBCameraViewController/Classes/**/*'
  s.resources = ['CBCameraViewController/Assets/*.xcassets']

  #s.resource_bundles = {
  #  'CBCameraViewController' => ['CBCameraViewController/Assets/*.png']
  #}

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SnapKit'
  s.dependency 'CameraManager'
end
