#
# Be sure to run `pod lib lint LPThirdPlatformKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'LPThirdPlatformKit'
  s.version          = '0.1.0'
  s.summary          = 'A short description of LPThirdPlatformKit.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'http://10.0.7.12/soft/ios-modules/glithirdplatformkit'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'fanshengle' => '1316838962@qq.com' }
  s.source           = { :git => 'http://10.0.7.12/soft/ios-modules/glithirdplatformkit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '12.0'
  #允许导入静态库
  #s.static_framework = true
  #pod库的源文件
  s.source_files = 'LPThirdPlatformKit/Classes/*'
  s.frameworks = 'UIKit', 'Foundation'
  #资源文件
  s.resource_bundles = {
    'LPThirdPlatformKit' => ['LPThirdPlatformKit/Assets/*.xcassets']
  }
  
  # UMeng相关SDK，链接静态库或动态库时，动态的给模块的 Other Linker Flags 添加 -ObjC
  #-ObjC属于链接库必备参数，如果不加此项，会导致库文件无法被正确链接，SDK无法正常运行，这一步设置很重要
  s.pod_target_xcconfig = {'OTHER_LDFLAGS' => '-ObjC'}
  
  #三方平台授权（登录或分享）API 文件存放位置
  s.subspec 'Auth' do |authspec|
    
    authspec.source_files = 'LPThirdPlatformKit/Classes/Auth/*'
    
    #高德地图
    authspec.subspec 'Map' do |ss|

      ss.source_files = 'LPThirdPlatformKit/Classes/Auth/Map/**/*'

      #依赖的模块
#      ss.dependency 'LPThirdPlatformKit/Auth/Core'
      ss.dependency 'LPThirdPlatformKit/AMapLocationSDK'
    end
 
  end
    
    #存放高德地图的相关SDK（framwork、a）
    s.subspec 'AMapLocationSDK' do |ss|

#      #pod源文件，显示地图头文件，暴露  LPThirdPlatformKit/AMMapSDK/**/*Kit.h
#      ss.source_files = 'LPThirdPlatformKit/AMapLocationSDK/AMapLocationKit.framework/**/AMapLocationKit.h'
      #依赖的第三方库
      ss.vendored_frameworks = [
      'LPThirdPlatformKit/AMapLocationSDK/**/*.framework',
      ]
      #依赖的系统库
      ss.frameworks = [
      'Security',
      'CoreMotion',
      'CoreLocation',
      'GLKit',
      'SystemConfiguration',
      'CoreTelephony',
      'CoreServices'
      ]
      ss.libraries = [
      'c++',
      'z']

#      #资源文件
      ss.resources = [
#      'LPThirdPlatformKit/AMMapSDK/AMapNaviKit.framework/*.bundle',
#      'LPThirdPlatformKit/AMMapSDK/MAMapKit.framework/AMap.bundle'
      ]


    end

end
