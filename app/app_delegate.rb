class AppDelegate
  def application(application, didFinishLaunchingWithOptions:launchOptions)
    @window = UIWindow.alloc.initWithFrame(UIScreen.mainScreen.bounds)
    @window.rootViewController = UINavigationController.alloc.initWithRootViewController(CrimeMapController.alloc.init)
    @window.rootViewController.wantsFullScreenLayout = true
    @window.makeKeyAndVisible

    #NSSetUncaughtExceptionHandler(uncaughtExceptionHandler)
    #FlurryAnalytics.startSession("VNHHFKB2GK8BT22TPQRK")

    true
  end

  def uncaughtExceptionHandler(exception)
    #FlurryAnalytics.logError("Uncaught", message:"Crash!", exception:exception)
  end


end
