class AboutScreen < PM::WebScreen

  title "About"

  def content
    "AboutView.html"
  end

  def will_appear
    App::Persistence["seenAbout"] = "yes"
    @view_loaded ||= begin
      self.navigationController.navigationBar.barStyle = UIBarStyleBlack if Device.ios_version.to_f < 7.0
      set_nav_bar_right_button "Close", action: :close, type: UIBarButtonItemStyleDone
    end
  end

  #debugging function to output the html of the webview once loaded.
  #def webViewDidFinishLoad(webView)
  #  puts self.view.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('html')[0].outerHTML")
  #end

end
