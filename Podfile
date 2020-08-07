source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
platform :ios, '13.0'
install! 'cocoapods', :disable_input_output_paths => true

def google_utilites
  pod 'GTMSessionFetcher'
  pod 'GoogleUtilities/AppDelegateSwizzler'
  pod 'GoogleUtilities/Environment'
  pod 'GoogleUtilities/ISASwizzler'
  pod 'GoogleUtilities/Logger'
  pod 'GoogleUtilities/MethodSwizzler'
  pod 'GoogleUtilities/NSData+zlib'
  pod 'GoogleUtilities/Network'
  pod 'GoogleUtilities/Reachability'
  pod 'GoogleUtilities/UserDefaults'
end

def app_pods
  pod 'Branch'
  pod 'Cloudinary', '~> 2.0'
  pod 'CodableFirebase'
  pod 'FacebookCore'
  pod 'FBSDKCoreKit'  
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/Crashlytics'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'  
  pod 'Firebase/InAppMessaging'
  pod 'Firebase/Analytics'
  pod 'FirebaseFirestoreSwift'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Storage'  
  pod 'MarkdownKit', '1.5'
  pod "NoveFeatherIcons", "~> 1.0"  
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '5.1.10'  
  pod 'SwiftLint'      
end


def today_pods
    pod 'Cloudinary', '~> 2.0'
    pod 'CodableFirebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Firestore'
    pod 'FirebaseFirestoreSwift'
    pod 'Firebase/Storage'        
    pod 'MarkdownKit', '1.5'    
    pod "NoveFeatherIcons", "~> 1.0"    
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '5.1.10'    
end

target 'Cactus Stage' do  
  use_frameworks!
  inhibit_all_warnings!

  google_utilites
  app_pods
end

target 'Cactus Prod' do
  use_frameworks!
  inhibit_all_warnings!
  
  google_utilites
  app_pods
end

target 'Cactus Today Prod' do
  use_frameworks!
  inhibit_all_warnings!
  
  google_utilites
  today_pods
end

target 'Cactus UnitTests' do
  use_frameworks!
  inhibit_all_warnings!

  google_utilites
  app_pods
end


post_install do |installer|
  installer.pods_project.targets.each do |target|
    target.build_configurations.each do |config|
      if config.name == 'Debug'
        config.build_settings['OTHER_SWIFT_FLAGS'] = ['$(inherited)', '-Onone']
        config.build_settings['SWIFT_OPTIMIZATION_LEVEL'] = '-Owholemodule'
      end
      config.build_settings['LD_NO_PIE'] = 'NO'
    end
  end
end
