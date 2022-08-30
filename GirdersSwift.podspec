Pod::Spec.new do |s|
  s.name     = 'GirdersSwift'
  s.version = '0.6.0'
  s.summary  = 'Girders for iOS, written in Swift.'
  s.homepage = 'https://www.netcetera.com'
  s.author   = 'Netcetera'
  s.description = 'A library that reduces development time for iOS Swift applications.'
  s.platform = :ios, '11.0'
  s.source = { :git => 'https://github.com/netceteragroup/GirdersSwift.git', :tag => '0.6.0' }
  s.requires_arc = true
  s.swift_version = "5.0"
  s.module_name = 'GirdersSwift'
  s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/Sources/GirdersSwift',
                 'SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug]' => 'DEBUG' }
  s.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/Sources"',
                              'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }
  s.pod_target_xcconfig = { 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64' }

  s.license = { :type => 'commercial', :text => %{
                 The copyright to the computer program(s) herein is the property of
                 Netcetera AG, Switzerland.  The program(s) may be used and/or copied
                 only with the written permission of Netcetera AG or in accordance
                 with the terms and conditions stipulated in the agreement/contract
                 under which the program(s) have been supplied.2
              } }


  s.source_files = 'Sources/GirdersSwift/**/*.{swift}'
  s.dependency 'SwiftyBeaver', '1.9.5'
  s.dependency 'KeychainAccess', '4.2.2'
  s.dependency 'PromiseKit', '6.17.1'
  s.frameworks = 'Foundation', 'Security'
  s.vendored_frameworks = 'Sources/GRSecurity.xcframework'

end
