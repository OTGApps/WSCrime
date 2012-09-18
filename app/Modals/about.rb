=begin
Copyright (c) 2012 Mark Rickert

Permission is hereby granted, free of charge, to any person obtaining a copy of 
this software and associated documentation files (the "Software"), to deal in 
the Software without restriction, including without limitation the rights to 
use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies 
of the Software, and to permit persons to whom the Software is furnished to do 
so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in 
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR 
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, 
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE 
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER 
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, 
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN 
THE SOFTWARE.
=end

class AboutController < UIViewController

  def viewDidLoad
    super

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