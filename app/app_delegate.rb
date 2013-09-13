class AppDelegate < ProMotion::Delegate

  tint_color "#0F5D14".to_color

  def on_load(app, options)
    unless Device.simulator?
      NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
      Flurry.startSession("VNHHFKB2GK8BT22TPQRK")
    end

    Appirater.setAppId NSBundle.mainBundle.objectForInfoDictionaryKey('APP_STORE_ID')
    Appirater.setDaysUntilPrompt 5
    Appirater.setUsesUntilPrompt 10
    Appirater.setTimeBeforeReminding 5
    Appirater.appLaunched true

    open MapScreen.new(nav_bar: true)

    true
  end

  #Flurry exception handler
  def uncaughtExceptionHandler(exception)
    Flurry.logError("Uncaught", message:"Crash!", exception:exception)
  end

  def applicationWillEnterForeground(application)
    Appirater.appEnteredForeground true
  end

end
