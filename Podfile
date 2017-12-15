# Uncomment this line to define a global platform for your project
platform :ios, '9.0'
use_frameworks!
inhibit_all_warnings!

target 'KofktuSDK' do
  # Pods for KofktuSDK
  pod 'AlamofireObjectMapper', '~> 5.0'
  pod 'SDWebImage/GIF', '~> 4.0'
  pod 'Toaster', '~> 2.0'
  pod 'KeychainAccess', '~> 3.1'
  pod 'Sniffer', '~> 1.5.0'
  pod 'Dotzu'

  target 'KofktuSDKTests' do
    inherit! :search_paths
    # Pods for testing
  end

end

swift32 = ['Dotzu']

post_install do |installer|
    installer.pods_project.targets.each do |target|
        swift_version = '4.0'

        if swift32.include?(target.name)
            swift_version = '3.2'
        end

        target.build_configurations.each do |config|
            config.build_settings['SWIFT_VERSION'] = swift_version
        end
    end
end
