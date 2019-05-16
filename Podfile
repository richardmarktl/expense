source 'git@github.com:gekitz/mw-private-pods.git'
source 'https://github.com/CocoaPods/Specs.git'

# Uncomment the next line to define a global platform for your project
platform :ios, '11.1'
inhibit_all_warnings!

target 'expense' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  # Pods for expense
  pod 'SwiftLint', '~>0.23'
  pod 'SwiftyBeaver', '~> 1.7', :inhibit_warnings => true
  
  # Rx
  pod 'RxSwift','~> 4.5.0'
  pod 'RxCocoa', '~> 4.5.0'
  # pod 'RxStoreKit', '~> 1.2.1'
  
  # Invoice Bot Private Pods
  pod 'InvoiceBotSDK', '~> 1.0.7'
  pod 'CommonUI', '~> 0.0.19'
  pod 'SettingsUI', '~> 0.0.8'
  
  # Generator
  pod 'R.swift', '~> 5.0'

  # Date Helper
  pod 'SupportEmail', '~> 3.0.0'
  pod 'Kvitto', '~> 1.0.2'
  pod 'Charts', '~> 3.2.2'
  pod 'EmailValidator', :git => "https://github.com/gekitz/EmailValidator.git", :commit => "e39cb1f"
  
  pod 'Moya/RxSwift', '~> 12.0.1'
  pod 'Reachability', '~> 3.2'
  pod 'JLRoutes', '~> 2.1'
  pod 'SwiftRichString', '~> 3.0.0'
  
  # Database
  pod 'CoreDataExtensio', '~> 2.0.4'
  
  #Firebase (PN) and Fabric (Tracking)
  pod 'GoogleSignIn'
  pod 'FirebaseCore'
  pod 'FirebaseMessaging'
  pod 'FirebaseRemoteConfig'
  pod 'Crashlytics', '~> 3.12.0'
  pod 'Amplitude-iOS', '~> 4.6.0', :inhibit_warnings => true

  # ImageViever
  pod 'ImageViewer', :git => "https://github.com/Nabeatsu/ImageViewer.git"

  # Facebook
  pod 'FacebookCore', '~> 0.6.0', :inhibit_warnings => true
  
  # pod 'SimulatorStatusMagic', :configurations => ['expenseDev', 'expenseStg', 'expenseProd']
  # pod 'ShowTime', :configurations => ['expenseDev', 'expenseStg', 'expenseProd']
  
  # Signature
  pod 'SwiftSignatureView'
  
  target 'expenseTests' do
    inherit! :search_paths
    # Pods for testing
  end

  target 'expenseUITests' do
    inherit! :search_paths
    # Pods for testing
  end

end

post_install do |installer|
  installer.pods_project.targets.each do |target|

      if ['RxStoreKit'].include? target.name 
        puts "Manually updating DEBUG flag for build config of RxStoreKit to connect to correct iTC server"
        target.build_configurations.each do |config| 
          unless config.name.include? 'AppStore'
            config.build_settings['SWIFT_ACTIVE_COMPILATION_CONDITIONS'] = 'DEBUG' 
          end
        end
      end

      if ['Amplitude-iOS', 'Protobuf', 'FBSDKCoreKit', 'Bolts', 'DTFoundation'].include? target.name
        puts "Updating #{target.name} to inhibit all warnings"
        target.build_configurations.each do |config|
          config.build_settings['GCC_WARN_INHIBIT_ALL_WARNINGS'] = 'YES'
        end
      end
  end
end
