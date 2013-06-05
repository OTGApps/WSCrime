class UIWebView

  def removeShadow
	# Remove that dang shadow.from the UIWebView
  self.subviews.each do |web_scroll_view|
    if web_scroll_view.is_a?(UIScrollView)
      web_scroll_view.subviews.each do |scrollview_subview|
        if scrollview_subview.is_a?(UIImageView)
          scrollview_subview.image = nil if scrollview_subview.respond_to?("setImage=")
          scrollview_subview.backgroundColor = UIColor.clearColor if scrollview_subview.respond_to?("setBackgroundColor=")
        end
      end
    end
  end

  end

  def makeTransparent
    self.backgroundColor = UIColor.clearColor
    self.opaque = false
  end

  def makeTransparentAndRemoveShadow
    self.makeTransparent
    self.removeShadow
  end
end
