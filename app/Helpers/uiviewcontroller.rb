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

class UIViewController

  def setTitle(title, subtitle:subtitle)
    if subtitle.nil?
      self.title = title
      return
    end

    self.navigationItem.titleView = nil

    created = false
    titleView = self.navigationItem.titleView
    labelTitle = nil
    labelSubtitle = nil
    
    if titleView.nil?
        created = true
        
        titleView = UIView.alloc.initWithFrame CGRectZero
        labelTitle = UILabel.alloc.initWithFrame CGRectZero
        labelSubtitle = UILabel.alloc.initWithFrame CGRectZero
        
        labelTitle.backgroundColor = UIColor.clearColor
        labelTitle.textAlignment = UITextAlignmentCenter
        labelTitle.shadowColor = UIColor.darkGrayColor
        labelTitle.textColor = UIColor.whiteColor
        labelTitle.lineBreakMode = UILineBreakModeTailTruncation
        labelSubtitle.backgroundColor = UIColor.clearColor
        labelSubtitle.textAlignment = UITextAlignmentCenter
        labelSubtitle.textColor = UIColor.whiteColor
        labelSubtitle.shadowColor = UIColor.darkGrayColor
        labelSubtitle.lineBreakMode = UILineBreakModeTailTruncation
        labelTitle.font = UIFont.boldSystemFontOfSize 18
        labelSubtitle.font = UIFont.systemFontOfSize 14
        
        titleView.addSubview labelTitle
        titleView.addSubview labelSubtitle

    end
    
    labelTitle.text = title
    labelSubtitle.text = subtitle
    labelTitle.sizeToFit
    labelSubtitle.sizeToFit
    
    titleView.frame = CGRectMake(
      0, 
      0,
      [labelTitle.bounds.size.width, labelSubtitle.bounds.size.width].max,
      self.navigationController.navigationBar.bounds.size.height
    )
    
    labelTitle.center = CGPointMake(titleView.bounds.size.width / 2, 15)
    labelSubtitle.center = CGPointMake(titleView.bounds.size.width / 2, 31)
    labelTitle.frame = CGRectIntegral(labelTitle.frame)
    labelSubtitle.frame = CGRectIntegral(labelSubtitle.frame)
    
    titleView.autoresizesSubviews = true
    titleView.autoresizingMask = UIViewAutoresizingFlexibleWidth | 
                                 UIViewAutoresizingFlexibleLeftMargin | 
                                 UIViewAutoresizingFlexibleRightMargin
    labelTitle.autoresizingMask = titleView.autoresizingMask
    labelSubtitle.autoresizingMask = titleView.autoresizingMask
        
    if created
      self.navigationItem.titleView = titleView;
    end

  end

end