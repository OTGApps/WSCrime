class MyNavigationController < UINavigationController

	def supportedInterfaceOrientations
    	self.topViewController.supportedInterfaceOrientations
  end

end