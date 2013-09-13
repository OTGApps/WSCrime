class CalendarScreen < ProMotion::Screen
  title "Select a Date:"

  def will_appear
  	@view_setup ||= begin
			set_nav_bar_right_button "Cancel", action: :close, type: UIBarButtonItemStyleDone
	    self.navigationController.navigationBar.barStyle = UIBarStyleBlack if Device.ios_version.to_f < 7.0
    	view.scrollToDate(view.selectedDate, animated:true)
  	end
  end

  def close
  	self.navigationController.dismissModalViewControllerAnimated(true)
  end

end
