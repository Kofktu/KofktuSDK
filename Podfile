# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'KofktuSDK' do
  # Pods for KofktuSDK
  pod 'KofktuSDK', :path => './'
  
  target 'KofktuSDKTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

swift42 = ['AlamofireObjectMapper']

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '5.0'

        if swift42.include?(target.name)
            swift_version = '4.2'
        end

        target.build_configurations.each do |config|
            config.build_settings.delete('CODE_SIGNING_ALLOWED')
            config.build_settings.delete('CODE_SIGNING_REQUIRED')
            config.build_settings['SWIFT_VERSION'] = swift_version

            # Do not need debug information for pods
            config.build_settings['DEBUG_INFORMATION_FORMAT'] = 'dwarf'

            # Disable Code Coverage for Pods projects - only exclude ObjC pods
            config.build_settings['CLANG_ENABLE_CODE_COVERAGE'] = 'NO'
            config.build_settings['LD_RUNPATH_SEARCH_PATHS'] = ['$(FRAMEWORK_SEARCH_PATHS)']

            if config.name == 'Debug'
                config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
                config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
            end

        end
    end
end
