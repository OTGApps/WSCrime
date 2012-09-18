# -*- coding: utf-8 -*-
$:.unshift("/Library/RubyMotion/lib")
require 'motion/project'
require 'bundler'
Bundler.setup
Bundler.require

Motion::Project::App.setup do |app|
  app.name = 'W-S Crime'
  app.identifier = 'com.mohawkapps.Winston-Salem-Crime'
  app.frameworks += ['CoreLocation', 'MapKit']
  app.device_family = [:iphone, :ipad]
  app.version = '1.5'
  app.short_version = '7'
  app.interface_orientations = [:portrait, :landscape_left, :landscape_right, :portrait_upside_down]
  app.sdk_version = "6.0"
  app.deployment_target = "5.0"

  #Add Flurry Analytics as a static library.
  app.vendor_project('vendor/FlurryAnalytics', :static,
    :products => ['libFlurryAnalytics.a'],
    :headers_dir => 'vendor/FlurryAnalytics')

  app.pods do
    pod 'CKCalendar'
    pod 'NSDate-Extensions'
    pod 'Appirater'
  end

  app.codesign_certificate = "iPhone Developer: Mark Rickert (YA2VZGDX4S)"
  app.development do
    app.entitlements['get-task-allow'] = true
    app.provisioning_profile = "/Volumes/mrickert/Library/MobileDevice/Provisioning\ Profiles/EF63CB15-B5E7-4FB6-9A8C-07A8F09AA8AD.mobileprovision"  
  end

  app.release do
    app.provisioning_profile = "/Volumes/mrickert/Library/MobileDevice/Provisioning\ Profiles/398F0715-559F-4861-8FF4-D828F6263DC6.mobileprovision"  
  end

end

desc "Open latest crash log"
task :log do
  app = Motion::Project::App.config
  exec "less '#{Dir[File.join(ENV['HOME'], "/Library/Logs/DiagnosticReports/#{app.name}*")].last}'"
end

# Rake helper tasks

desc "Run simulator in retina mode"
task :retina do
  exec "bundle exec rake simulator retina=true"
end

desc "Run simulator on iPad"
task :ipad do
  exec "bundle exec rake simulator device_family=ipad"
end

desc "Run simulator on iPad in retina mode"
task :ipadretina do
  exec "bundle exec rake simulator retina=true device_family=ipad"
end
