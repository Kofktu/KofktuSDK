# Uncomment this line to define a global platform for your project
# platform :ios, '9.0'

target 'KofktuSDK' do
  # Comment this line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!

  # Pods for KofktuSDK
  pod 'Alamofire', '~> 4.0'
  pod 'ObjectMapper', '~> 2.0'
  pod 'AlamofireObjectMapper', '~> 4.0.1'
  pod 'Timberjack', :git => 'git@github.com:Kofktu/Timberjack.git', :tag => 'swift_3_0'
  pod 'SDWebImage', '~> 3.8.0'
  pod 'AsyncSwift', '~> 2.0'

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
