# UINavigationController subclass to to help handle orientation changes, etc.
class PortraitNavigationController < UINavigationController

	def supportedInterfaceOrientations
    # Only allow landscape if they're on an iPad
    if Device.iphone?
      UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
    else
      UIInterfaceOrientationMaskAll
    end
  end

  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    if Device.iphone?
      interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown
    else
      true
    end
  end

end
