platform :ios,'7.0'

xcodeproj 'DYMovidePlayer.xcodeproj' 

#################################################################################################
 
pod 'DYMovidePlayer', :path => './DYMovidePlayer.podspec'
  
#强制更改依赖版本是部分控件存在bug，不支持6.0，直接修改  config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "6.0"
post_install do |installer|
    
    installer.project.build_configurations.each do |config| 
        config.build_settings['SDKROOT'] = "iphoneos"
        config.build_settings['ARCHS'] = "armv7 armv7s"
        config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "6.0"
    end
    
    installer.project.targets.each do |target|
        target.build_configurations.each do |config|
            config.build_settings['ARCHS'] = "armv7 armv7s"
            config.build_settings['GCC_WARN_UNDECLARED_SELECTOR'] = "NO"
            config.build_settings['IPHONEOS_DEPLOYMENT_TARGET'] = "6.0"
            
        end
    end
end

