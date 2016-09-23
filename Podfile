use_frameworks!
platform :ios, '9.0'
source 'https://github.com/CocoaPods/Specs.git'

# ignore all warnings from all pods
inhibit_all_warnings!

project 'AWSBased_SwiftAppDemo.xcodeproj'
target 'AWSBased_SwiftAppDemo' do
  # AWS
  pod 'AWSCore', '~> 2.4.9'
  pod 'AWSCognitoIdentityProvider', '~> 2.4.9'
  pod 'AWSCognito', '~> 2.4.9'
  
  # Social
  pod 'FBSDKCoreKit', '~> 4.15.0'
  pod 'FBSDKLoginKit', '~> 4.15.0'
  
  # Few nice additions
  pod 'SVProgressHUD', '~> 2.0.3'
  pod 'R.swift', '~> 3.0.0'
  pod 'UICKeyChainStore', '~> 2.0.6'
  
  # To ensure we select swift version for all pod targets
  post_install do |installer|
      installer.pods_project.targets.each do |target|
          target.build_configurations.each do |configuration|
              configuration.build_settings['SWIFT_VERSION'] = "3.0"
          end
      end
  end
end
