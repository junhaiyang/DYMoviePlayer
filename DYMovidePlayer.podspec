 
Pod::Spec.new do |s|
 

  s.name         = "DYMovidePlayer"
  s.version      = "1.0"
  s.summary      = "DYMovidePlayer  "
 

  s.homepage     = "https://github.com/junhaiyang/DYMovidePlayer"
 
  s.license      = "MIT"
 
  s.author             = { "yangjunhai" => "junhaiyang@gmail.com" } 
  s.ios.deployment_target = "6.0" 

  s.ios.frameworks = 'UIKit','AVFoundation','QuartzCore','MediaPlayer'
 
  s.source = { :git => 'https://github.com/junhaiyang/DYMovidePlayer.git' , :tag => '1.0'} 
 
  s.requires_arc = true
   
  s.source_files = 'player/*.{h,m,mm}'   
    	 
   
 
end
