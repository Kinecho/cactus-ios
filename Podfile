source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'
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
  pod 'Firebase/Crashlytics'
  pod 'CodableFirebase'
  pod 'Firebase/Auth'
  pod 'Firebase/Core'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  pod 'Firebase/Performance'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  pod 'Firebase/InAppMessaging'
  pod 'Firebase/Analytics'
  pod 'FirebaseUI'
  pod 'FirebaseUI/Storage'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.4.1'
  pod 'MarkdownKit', '1.5'
  pod 'Cloudinary', '~> 2.0'
  pod 'SwiftLint'
  pod 'FBSDKCoreKit'
  pod 'FacebookCore'
  pod 'Branch'
  pod 'SkeletonView'
  pod 'Purchases', '3.2.2'
end


def today_pods
    pod 'CodableFirebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Cloudinary', '~> 2.0'
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.4.1'
    pod 'MarkdownKit', '1.5'
    pod 'SkeletonView'
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
