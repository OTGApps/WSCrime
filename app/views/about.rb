class AboutController < UIViewController

  def viewDidLoad
    self.title = "About"
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack

    backButton = UIBarButtonItem.alloc.initWithTitle(
      "Done",
      style:UIBarButtonItemStyleDone,
      target:self,
      action:"closeModal")
    self.navigationItem.rightBarButtonItem = backButton;

    self.view = UIWebView.alloc.init
    view.delegate = self

    aboutContent = File.read(App.resources_path + "/AboutView.html")
    baseURL = NSURL.fileURLWithPath(App.resources_path)

    #Convert images over to retina if the images exist.
    if Device.retina?
      aboutContent.gsub!(/src=['"](.*)\.(jpg|gif|png)['"]/) do |img|
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

  #debugging function to output the html of the webview once loaded.
  #def webViewDidFinishLoad(webView)
  #  puts self.view.stringByEvaluatingJavaScriptFromString("document.getElementsByTagName('html')[0].outerHTML")
  #end

  def closeModal
    self.navigationController.dismissModalViewControllerAnimated(true)
  end

  #Open UIWebView delegate links in Safari.
  def webView(inWeb, shouldStartLoadWithRequest:inRequest, navigationType:inType)
    if inType == UIWebViewNavigationTypeLinkClicked
      UIApplication.sharedApplication.openURL(inRequest.URL)
      false #don't allow the web view to load the link.
    end
    true #return true for local file loading.
  end

end
