class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = PortraitNavigationController.alloc.initWithRootViewController(MapController.alloc.init)
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
    Flurry.startSession("VNHHFKB2GK8BT22TPQRK")
    if Device.simulator?
      Flurry.setUserID('simulator')
    end

    Appirater.setAppId NSBundle.mainBundle.objectForInfoDictionaryKey('APP_STORE_ID')
    Appirater.setDaysUntilPrompt 5
    Appirater.setUsesUntilPrompt 10
    Appirater.setTimeBeforeReminding 5
    Appirater.appLaunched true

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
