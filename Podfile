platform :ios, :deployment_target => '9.0'

source 'https://cdn.cocoapods.org/'

use_frameworks!

target :GirdersSwift do
  pod 'SwiftyBeaver', '~> 1.7'
  pod 'PromiseKit', '~> 6.8'
  pod 'KeychainAccess', '~> 3.2'
end

target :UnitTest do
  pod 'SwiftyBeaver', '~> 1.7'
  pod 'OHHTTPStubs/Swift', '~> 7.0'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
	         config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
           config.build_settings.delete 'IPHONEOS_DEPLOYMENT_TARGET'
        end
    end
end
