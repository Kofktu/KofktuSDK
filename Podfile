# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'KofktuSDK' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KofktuSDK
  pod 'Alamofire', '3.5.0'
  pod 'ObjectMapper', '1.4.0'
  pod 'AlamofireObjectMapper', '3.0.2'
  pod 'Timberjack'
  pod 'SDWebImage', '~>3.7'
  pod 'AsyncSwift', '1.7.4'

  target 'KofktuSDKTests' do
    inherit! :search_paths
    # Pods for testing
  end

end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      config.build_settings['SWIFT_VERSION'] = '2.3'
    end
  end
end
