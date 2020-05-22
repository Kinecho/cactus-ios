source 'https://cdn.cocoapods.org/'

# Uncomment the next line to define a global platform for your project
 platform :ios, '12.0'

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
#    pod 'Firebase/Analytics'
    pod 'Cloudinary', '~> 2.0'
    pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.4.1'
    pod 'MarkdownKit', '1.5'
    pod 'SkeletonView'
#    pod 'FBSDKCoreKit'
#    pod 'FacebookCore'
end

target 'Cactus Stage' do  
  use_frameworks!
  inhibit_all_warnings!
  
  app_pods
  
end

target 'Cactus Prod' do
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
