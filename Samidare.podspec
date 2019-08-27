#
# Be sure to run `pod lib lint Samidare.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see http://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'Samidare'
  s.version          = '1.0-beta.2'
  s.summary          = 'A short description of Samidare.'
  s.ios.deployment_target = '11.0'
  s.swift_version = '5.0'
  s.source_files = 'Samidare/Classes/**/*'
  s.source           = { :git => 'https://github.com/131e55/Samidare.git', :tag => s.version.to_s }
  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC
  s.homepage         = 'https://github.com/131e55/Samidare'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Keisuke Kawamura' => '' }
  s.social_media_url = 'https://twitter.com/131e55'
 end
