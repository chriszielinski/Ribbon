Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.name                  = 'Ribbon'
  s.version               = '1.0'
  s.summary               = '🎀 A simple cross-platform toolbar/custom input accessory view library for iOS & macOS. Written in Swift.'
  s.homepage              = 'https://github.com/chriszielinski/Ribbon'
  s.screenshots           = 'https://raw.githubusercontent.com/chriszielinski/Ribbon/master/.readme-assets/header.jpg'


  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.license               = { :type => 'MIT', :file => 'LICENSE' }


  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.author                = { 'chriszielinski' => 'chrisz@berkeley.edu' }
  s.social_media_url      = 'https://twitter.com/mightbesuperman'


  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.ios.deployment_target = '10.0'
  s.osx.deployment_target = '10.12'


  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source                = { :git => 'https://github.com/chriszielinski/Ribbon.git', :tag => s.version.to_s }


  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #

  s.source_files     = 'Ribbon/**/*.swift'
  s.swift_version    = "5"

end
