source 'https://github.com/CocoaPods/Specs.git'

# ==============
#
# Attention
#
# Before installing Au10tix pods for the first time
# execute the next command in your terminal
# pod repo add AU10TIX_IOS_ARTIFACTS_GITHUB https://github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git
#
# In order to obtain personal access token - contact support.
#
# ==============

source 'https://github.com/au10tixmobile/iOS_Artifacts_cocoapods_spec.git'

target 'Au10tixSimpleSample' do
  # Comment the next line if you don't want to use dynamic frameworks
  use_frameworks!
  pod 'Au10tixSecureMeKit'
  pod 'Au10tixPassiveFaceLivenessUI'
  pod 'Au10tixProofOfAddressUI'
  pod 'Au10tixSmartDocumentCaptureUI'
  pod 'Au10tixLivenessUI'
  pod 'Au10tixBEKit'
  post_install do |installer|
    installer.pods_project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['EXPANDED_CODE_SIGN_IDENTITY'] = ""
            config.build_settings['CODE_SIGNING_REQUIRED'] = "NO"
            config.build_settings['CODE_SIGNING_ALLOWED'] = "NO"
            config.build_settings['ENABLE_BITCODE'] = 'NO'
        end
    end
  end

  
end
