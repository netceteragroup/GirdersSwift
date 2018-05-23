platform :ios, :deployment_target => '9.0'

source 'https://github.com/CocoaPods/Specs.git'

use_frameworks!

target :GirdersSwift do
  pod 'SwiftyBeaver'
  pod 'PromiseKit'
  pod 'KeychainAccess'
end

target :UnitTest do
  pod 'SwiftyBeaver'
  pod 'OHHTTPStubs/Swift'
end

post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
	    config.build_settings['CLANG_ALLOW_NON_MODULAR_INCLUDES_IN_FRAMEWORK_MODULES'] = 'YES'
        end
    end
end
