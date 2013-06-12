class AboutScreen < PM::Screen

  title "About"

  def will_appear

    App::Persistence["seenAbout"] = "yes"

    @view_loaded ||= begin
      self.navigationController.navigationBar.barStyle = UIBarStyleBlack

      set_nav_bar_right_button "Done", action: :close_modal, type: UIBarButtonItemStyleDone

      self.view = UIWebView.new
      view.delegate = self

      aboutContent = File.read(App.resources_path + "/AboutView.html")
      baseURL = NSURL.fileURLWithPath(App.resources_path)

      #Convert images over to retina if the images exist.
      if Device.retina?
        aboutContent.gsub!(/src=['"](.*?)\.(jpg|gif|png)['"]/) do |img|
          if File.exists?(App.resources_path + "/#{$1}@2x.#{$2}")
            uiImage = UIImage.imageNamed("/#{$1}@2x.#{$2}")

            newWidth = uiImage.size.width / 2
            newHeight = uiImage.size.height / 2

            img = "src=\"#{$1}@2x.#{$2}\" width=\"#{newWidth}\" height=\"#{newHeight}\""
          end
        end
      end

      self.view.loadHTMLString(aboutContent, baseURL:baseURL)
    end
  end

  #debugging function to output the html of the webview once loaded.
  #def webViewDidFinishLoad(webView)
  #  puts self.view.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('html')[0].outerHTML")
  #end

  def close_modal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

  #Open UIWebView delegate links in Safari.
  def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
    if inType == UIWebViewNavigationTypeLinkClicked
      UIApplication.sharedApplication.openURL(inRequest.URL)
      return false #don't allow the web view to load the link.
    end
    true #return true for local file loading.
  end

end
