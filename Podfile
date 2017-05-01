# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'KofktuSDK' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KofktuSDK
  pod 'Alamofire', '~> 4.0'
  pod 'ObjectMapper', '~> 2.0'
  pod 'AlamofireObjectMapper', '~> 4.0'
  pod 'SDWebImage', '~> 4.0'
  pod 'AsyncSwift', '~> 2.0'
  pod 'Toaster', '~> 2.0'
  pod 'KeychainAccess', '~> 3.0'
  pod 'Sniffer'

  target 'KofktuSDKTests' do
    inherit! :search_paths
    # Pods for testing
  end

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '3.0'
    end
  end
end
