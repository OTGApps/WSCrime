# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'W-S Crime'
  app.identifier = 'com.mohawkapps.Winston-Salem-Crime'
  app.frameworks += ['CoreLocation', 'MapKit']
  app.device_family = [:iphone, :ipad]
  #app.icons = ["Icon-72.png", "Icon-72@2x.png", "Icon-Small-50.png", "Icon-Small.png", "Icon-Small@2x.png", "Icon.png", "Icon@2x.png"]
  app.interface_orientations = [:portrait, :landscape_left, :landscape_right, :portrait_upside_down]
  app.deployment_target = "5.0"

  app.pods do
    pod 'CKCalendar'
    pod 'NSDate-Extensions'
    #pod 'FlurrySDK'
  end

  app.development do
    # This entitlement is required during development but must not be used for release.
    app.entitlements['get-task-allow'] = true
  end

end
