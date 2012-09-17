class AppDelegate

  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(CrimeMapController.alloc.init)
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    #NSSetUncaughtExceptionHandler(NSUncaughtExceptionHandler* )
    #NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
    FlurryAnalytics.startSession("VNHHFKB2GK8BT22TPQRK")
    FlurryAnalytics.setUserID('markrickert')

    true
  end

  #Flurry exception handler
  #Commented out till I can figure out how to implement Flurry
  #def uncaughtExceptionHandler(exception)
  #  FlurryAnalytics.logError("Uncaught", message:"Crash!", exception:exception)
  #end

end
