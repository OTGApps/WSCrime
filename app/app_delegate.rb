class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = MyNavigationController.alloc.initWithRootViewController(MapController.alloc.init)
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    NSSetUncaughtExceptionHandler("uncaughtExceptionHandler")
    FlurryAnalytics.startSession("VNHHFKB2GK8BT22TPQRK")
    FlurryAnalytics.setUserID('markrickert')

    Appirater.setAppId "472546582"
    Appirater.setDaysUntilPrompt 5
    Appirater.setUsesUntilPrompt 10
    Appirater.setTimeBeforeReminding 5
    Appirater.appLaunched true

    true
  end

  #Flurry exception handler
  #Commented out till I can figure out how to implement Flurry
  def uncaughtExceptionHandler(exception)
    FlurryAnalytics.logError("Uncaught", message:"Crash!", exception:exception)
  end

  def applicationWillEnterForeground(application)
    Appirater.appEnteredForeground true
  end

end
