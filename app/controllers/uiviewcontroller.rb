class UIViewController

  def setTitle(title, subtitle:subtitle)
    # standard title
    if subtitle.nil?
        self.title = title
        return
    end

    # FIXME: restart from scratch
    self.navigationItem.titleView = nil

    # FIXME: fixed color

    created = false
    titleView = self.navigationItem.titleView
    labelTitle = nil
    labelSubtitle = nil

    if titleView.nil?
        ap "Creating titleview"
        created = true

        titleView = UIView.alloc.initWithFrame CGRectZero
        labelTitle = UILabel.alloc.initWithFrame CGRectZero
        labelSubtitle = UILabel.alloc.initWithFrame CGRectZero

        # titleView.layer.borderColor = UIColor.redColor.CGColor
        # titleView.layer.borderWidth = 1.0

        # labelTitle.layer.borderColor = UIColor.blueColor.CGColor
        # labelTitle.layer.borderWidth = 1.0

        # labelSubtitle.layer.borderColor = UIColor.greenColor.CGColor
        # labelSubtitle.layer.borderWidth = 1.0

        labelTitle.backgroundColor = UIColor.clearColor
        labelTitle.textAlignment = UITextAlignmentCenter
        labelTitle.lineBreakMode = UILineBreakModeTailTruncation
        labelSubtitle.backgroundColor = UIColor.clearColor
        labelSubtitle.textAlignment = UITextAlignmentCenter
        labelSubtitle.lineBreakMode = UILineBreakModeTailTruncation
        labelTitle.font = UIFont.boldSystemFontOfSize(18)
        labelSubtitle.font = UIFont.systemFontOfSize(14)

        labelTitle.textColor = UIColor.whiteColor
        labelTitle.shadowColor = UIColor.darkGrayColor
        labelSubtitle.textColor = labelTitle.textColor
        labelSubtitle.shadowColor = labelTitle.shadowColor
        labelSubtitle.shadowOffset = labelTitle.shadowOffset

        titleView.addSubview labelTitle
        titleView.addSubview labelSubtitle
    end

    labelTitle.text = title
    labelSubtitle.text = subtitle
    labelTitle.sizeToFit
    labelSubtitle.sizeToFit

    ap self.interfaceOrientation

    if [UIInterfaceOrientationPortrait, UIInterfaceOrientationPortraitUpsideDown].include? self.interfaceOrientation
      titleView.frame = CGRectMake(0, 0, [labelTitle.bounds.size.width, labelSubtitle.bounds.size.width].max, self.navigationController.navigationBar.bounds.size.height)
      labelTitle.center = CGPointMake(titleView.bounds.size.width / 2, 15)
      labelSubtitle.center = CGPointMake(titleView.bounds.size.width / 2, 31)
    else
      titleView.frame = CGRectMake(0, 0, [labelTitle.bounds.size.width, labelSubtitle.bounds.size.width].max, self.navigationController.navigationBar.bounds.size.height)
      labelTitle.center = CGPointMake(titleView.bounds.size.width / 2, 13)
      labelSubtitle.center = CGPointMake(titleView.bounds.size.width / 2, 28)
    end

    labelTitle.frame = CGRectIntegral(labelTitle.frame)
    labelSubtitle.frame = CGRectIntegral(labelSubtitle.frame)
    titleView.autoresizesSubviews = true
    titleView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin
    labelTitle.autoresizingMask = titleView.autoresizingMask
    labelSubtitle.autoresizingMask = titleView.autoresizingMask

    if created
        self.navigationItem.titleView = titleView
    end
  end

end
