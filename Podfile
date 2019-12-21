# Uncomment the next line to define a global platform for your project
platform :ios, '12.0'

def app_pods
#  pod 'Crashlytics'
  pod 'CodableFirebase'
  # pod 'Fabric'
  pod 'Firebase/Auth'
  pod 'FirebaseCore'
  pod 'Firebase/DynamicLinks'
  pod 'Firebase/Messaging'
  # pod 'Firebase/Performance'
  pod 'Firebase/Storage'
  pod 'Firebase/Firestore'
  #  pod 'FirebaseUI'
  #  pod 'FirebaseUI/Storage'
  # Only pull in Firestore features
  pod 'FirebaseUI/Firestore'
  
  # Only pull in Database features
  # pod 'FirebaseUI/Database'
  
  # Only pull in Storage features
  pod 'FirebaseUI/Storage'
  
  # Only pull in Auth features
  pod 'FirebaseUI/Auth'
  pod 'FirebaseUI/OAuth'

  # Only pull in Facebook login features
#  pod 'FirebaseUI/Facebook', '~> 8.0'
  
  # Only pull in Google login features
  # pod 'FirebaseUI/Google'
  
  # Only pull in Phone Auth login features
  # pod 'FirebaseUI/Phone'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.4.1'
  pod 'MarkdownKit'
  pod 'Cloudinary', '~> 2.0'
  pod 'SwiftLint'
  #  pod 'SwiftyGif' implemented on our ownii
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

target 'Cactus UnitTests' do
  use_frameworks!
  inhibit_all_warnings!
  app_pods
end
