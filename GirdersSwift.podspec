Pod::Spec.new do |s|
  s.name     = 'GirdersSwift'
  s.version = '0.2.9'
  s.summary  = 'Girders for iOS, written in Swift.'
  s.homepage = 'http://www.netcetera.com'
  s.author   = 'Netcetera'
  s.description = 'A library that reduces development time for iOS Swift applications.'
  s.platform = :ios, '9.0'
  s.source = { :git => 'https://github.com/netceteragroup/GirdersSwift.git', :tag => '0.2.9' }
  s.requires_arc = true
  s.swift_version = "4.1"
  s.module_name = 'GirdersSwift'
  s.xcconfig = { 'SWIFT_INCLUDE_PATHS' => '$(PODS_ROOT)/GirdersSwift',
                 'SWIFT_ACTIVE_COMPILATION_CONDITIONS[config=Debug]' => 'DEBUG' }
  s.user_target_xcconfig = { 'FRAMEWORK_SEARCH_PATHS' => '"${PODS_ROOT}/GirdersSwift/framework"' }

  s.license = { :type => 'commercial', :text => %{
                 The copyright to the computer program(s) herein is the property of
                 Netcetera AG, Switzerland.  The program(s) may be used and/or copied
                 only with the written permission of Netcetera AG or in accordance
                 with the terms and conditions stipulated in the agreement/contract
                 under which the program(s) have been supplied.2
              } }


  s.source_files = 'GirdersSwift/src/main/**/*.{swift}'
  s.dependency 'SwiftyBeaver', '1.5.2'
  s.dependency 'KeychainAccess', '3.1.1'
  s.dependency 'PromiseKit', '6.2.7'
  s.frameworks = 'Foundation', 'Security'
  s.vendored_frameworks = 'framework/GRSecurity.framework'

end
