class AboutScreen < PM::WebScreen

  title "About"

  def content
    "AboutView.html"
  end

  def will_appear
    App::Persistence["seenAbout"] = "yes"
    @view_loaded ||= begin
      self.navigationController.navigationBar.barStyle = UIBarStyleBlack
      set_nav_bar_right_button "Done", action: :close_modal, type: UIBarButtonItemStyleDone
    end
  end

  #debugging function to output the html of the webview once loaded.
  #def webViewDidFinishLoad(webView)
  #  puts self.view.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('html')[0].outerHTML")
  #end

  def close_modal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

end
