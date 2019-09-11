# Uncomment the next line to define a global platform for your project
# platform :ios, '9.0'

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
  pod 'FirebaseUI'
  pod 'FirebaseUI/Storage'
  pod 'Sentry', :git => 'https://github.com/getsentry/sentry-cocoa.git', :tag => '4.3.1'
  pod 'Down' #markdown library
  pod 'MarkdownKit'

end


target 'Cactus Stage' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  app_pods
end

target 'Cactus Prod' do
  # Comment the next line if you're not using Swift and don't want to use dynamic frameworks
  use_frameworks!
  
  app_pods
end
