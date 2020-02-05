# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

def app_pods
  pod 'Crashlytics'
  pod 'CodableFirebase'
  pod 'Fabric'
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
  pod 'MarkdownKit'
  pod 'Cloudinary', '~> 2.0'
  pod 'SwiftLint'
  pod 'FBSDKCoreKit'
  pod 'FacebookCore'
  pod 'Branch'
#  pod 'FBSDKLoginKit'
#  pod 'FBSDKShareKit'

  pod 'SkeletonView'
end


def today_pods
    pod 'CodableFirebase'
    pod 'Firebase/Auth'
    pod 'Firebase/Core'
    pod 'Firebase/Firestore'
    pod 'Firebase/Storage'
    pod 'Cloudinary', '~> 2.0'
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.4.1'
    pod 'MarkdownKit'
    pod 'SkeletonView'
end

target 'Cactus Stage' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!
  
  app_pods
  
end

target 'Cactus Prod' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  inhibit_all_warnings!

  app_pods
end

target 'Cactus Today Prod' do
  use_frameworks!
  inhibit_all_warnings!
  
  today_pods
end

target 'Cactus UnitTests' do
  use_frameworks!
  inhibit_all_warnings!
  app_pods
end
