class CrimeMapController < UIViewController

  def viewDidLoad
    super

    @mapView = MKMapView.alloc.initWithFrame(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
    @mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view.addSubview(@mapView)
    @mapView.delegate = self

    #Init instance values
    @didInitialZoom = false
    @didInitialPinZoom = false
    @theDate = NSDate.date
    @thePoints = NSMutableArray.alloc.init

  	#Set the application title
  	self.title = "Winston-Salem Crime Map"
    
    #Setup the toolbar and navigationbar
    self.navigationController.setToolbarHidden(false)
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;

    #Create buttons
    reZoomButton = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("location.png"), 
      style: UIBarButtonItemStyleBordered, 
      target: self, 
      action: "rezoom:")
  	self.navigationItem.rightBarButtonItem = reZoomButton

  	buttonItem1 = UIBarButtonItem.alloc.initWithTitle(
		  "About",
  		style: UIBarButtonItemStyleBordered,
  		target: self,
  		action: "loadAboutWindow:")
  	flexibleSpace = UIBarButtonItem.alloc.initWithBarButtonSystemItem(
  		UIBarButtonSystemItemFlexibleSpace,
  		target:nil,
  		action:nil)

  	@activityView = UIActivityIndicatorView.alloc.initWithActivityIndicatorStyle(UIActivityIndicatorViewStyleWhite)
  	@activityView.hidesWhenStopped = true
  	@activityView.startAnimating()
  	@activityViewButton = UIBarButtonItem.alloc.initWithCustomView(@activityView)

    @dateButton = UIBarButtonItem.alloc.initWithTitle(
      "Loading data from server...",
       style: UIBarButtonItemStyleBordered,
       target: self,
       action: "changeDate:")
    
    self.toolbarItems = [buttonItem1, flexibleSpace, @activityViewButton, @dateButton]

    #Send a request off to the server to get the data.
    loadData

  end

  def viewWillAppear(animated)
    
    #Check to see if we've loaded the view into WInston-Salem yet
    if @didInitialZoom == false

      #Center on Winston-Salem.
      metersPerMile = 1609.344
      initialLocation = CLLocationCoordinate2D.new(36.10, -80.26)
      region = MKCoordinateRegionMakeWithDistance(initialLocation, 4 * metersPerMile, 4 * metersPerMile)
      @mapView.setRegion(region, animated:true)

      @didInitialZoom = true
    else
      puts "Initial zoom already done."
    end

  end    

  def loadData

    @dateButton.title = "Loading data from server..."
    @activityView.startAnimating

    #Find the date to use
    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")
    dateString = dateFormat.stringFromDate(@theDate)

    BubbleWrap::HTTP.get("http://crimestats.mohawkapps.com/nc/winston-salem/?date=" + dateString) do |response|
        if response.ok?
          #p response.body.to_str

          json = BubbleWrap::JSON.parse(response.body.to_str)

          if json.count > 0
            @thePoints.removeAllObjects

            json.each do |crimeData|
              @thePoints.push(CrimeAnnotation.new(crimeData, crimeData['type']))
            end

            @activityView.stopAnimating
            replot

          else
            App.alert("No Results Found for that day.")
            @activityView.stopAnimating
            @dateButton.title = "No Results"
          end

          #p @thePoints

        else
          App.alert("Whoops! There was an error downloading data from the server. Please check your internet connection or try again later.")
          @activityView.stopAnimating
          @dateButton.title = "Server Error"
        end
    end

  end

  def replot
    p "Replotting"

    @dateButton.title = @theDate.to_s

    @mapView.annotations.each do |thisAnnotation|
      @mapView.removeAnnotation(thisAnnotation)
    end

    #Get the first crime
    firstAnnotation = @thePoints[0]
    #p firstAnnotation

    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")

    @theDate = dateFormat.dateFromString(firstAnnotation.date)
    newDate = NSDate.dateWithTimeInterval(0, sinceDate:@theDate)

    dateFormat.setDateFormat("MMM dd, yyyy")
    theNewDate = dateFormat.stringFromDate(@theDate)

    @dateButton.title = theNewDate

    p @thePoints.count
    @thePoints.each do |crime|
      @mapView.addAnnotation(crime)
    end

    if @didInitialPinZoom == false
      rezoom(nil)
      @didInitialPinZoom = true
    end

  end

  ViewIdentifier = 'ViewIdentifier'
  def mapView(mapView, viewForAnnotation:crime)
    if view = mapView.dequeueReusableAnnotationViewWithIdentifier(ViewIdentifier)
      view.annotation = crime
    else
      view = MKPinAnnotationView.alloc.initWithAnnotation(crime, reuseIdentifier:ViewIdentifier)
      view.canShowCallout = true
      view.animatesDrop = false
      view.pinColor = crime.pinColor
    end
    view
  end

  def rezoom(sender)

    #Don't attempt the rezoom of there are no pins
    if @mapView.annotations.count == 0
      false
    end

    #Set some boundaries
    topLeftCoord = CLLocationCoordinate2DMake(-90, 180)
    bottomRightCoord = CLLocationCoordinate2DMake(90, -180)

    #Find the bounds of the pins
    @mapView.annotations.each do |crime|
      topLeftCoord.longitude = [topLeftCoord.longitude, crime.coordinate.longitude].min
      topLeftCoord.latitude = [topLeftCoord.latitude, crime.coordinate.latitude].max
      bottomRightCoord.longitude = [bottomRightCoord.longitude, crime.coordinate.longitude].max
      bottomRightCoord.latitude = [bottomRightCoord.latitude, crime.coordinate.latitude].min 
    end

    coord = CLLocationCoordinate2DMake(
      topLeftCoord.latitude - (topLeftCoord.latitude - bottomRightCoord.latitude) * 0.5, 
      topLeftCoord.longitude + (bottomRightCoord.longitude - topLeftCoord.longitude) * 0.5)
    span = MKCoordinateSpanMake(
      ((topLeftCoord.latitude - bottomRightCoord.latitude) * 1.075).abs, 
      ((bottomRightCoord.longitude - topLeftCoord.longitude) * 1.075).abs)
    region = MKCoordinateRegionMake(coord, span)
    fits = @mapView.regionThatFits(region);
    @mapView.setRegion(fits, animated:true)
  end

  def loadAboutWindow(sender)
    aboutNavController = UINavigationController.alloc.initWithRootViewController(AboutController.alloc.init)
    self.navigationController.presentModalViewController(aboutNavController, animated:true)
  end

  def changeDate(sender)
    puts "Change the date"

    @animationTime = 0.25

    #Show the calendar.
    p @calendarHolder
    if @calendarHolder != nil
      destroyCalendar
      return
    end

    @calendarHolder = UIView.alloc.initWithFrame(@mapView.frame)
    @calendarView = CKCalendarView.alloc.initWithStartDay(1)
    @calendarView.delegate = self
    @calendarView.selectedDate = @theDate

    #Position the calendar view
    screenBounds = @mapView.bounds
    calendarWidth = 300
    calendarHeight = 300

    calendarBounds = CGRectMake(
      (screenBounds.size.width  - calendarWidth) / 2,
      (screenBounds.size.height  - calendarHeight) / 2,
      calendarWidth,
      calendarHeight)
      
    @calendarView.autoresizingMask = (
      UIViewAutoresizingFlexibleTopMargin |
      UIViewAutoresizingFlexibleBottomMargin |
      UIViewAutoresizingFlexibleLeftMargin |
      UIViewAutoresizingFlexibleRightMargin)
    
    @calendarView.frame = calendarBounds;
    @calendarView.setCenter(@mapView.center)

    @calendarHolder.addSubview(@calendarView)

    #@calendarHolder.whenTapped do
    #  destroyCalendar
    #end

    @calendarHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    @calendarHolder.alpha = 0
    @calendarView.alpha = 0
    @calendarHolder.backgroundColor = UIColor.colorWithWhite(0, alpha:0.5)

    self.view.addSubview(@calendarHolder)

    UIView.animateWithDuration(@animationTime,
        delay:0,
        options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState,
        animations: -> do
          @calendarHolder.alpha = 1;
          @calendarView.alpha = 1;
        end,
        completion: ->(finished) do
        end)
  end

  def calendar(calendar, didSelectDate:date)
    p "selecting date" + date.to_s

    if @theDate.isEqualToDate(date) == false

      if date.isLaterThanDate(NSDate.date)
        App.alert("The US. Department of Precognitive Crime has not been established yet.\n\nUntil then, please select a date in the past.")
        return;
      end
          
      @theDate = date
      loadData
    end

    destroyCalendar
  end



  def destroyCalendar
    UIView.animateWithDuration(@animationTime,
      delay:0,
      options:UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState,
      animations: -> do  
          @calendarHolder.alpha = 0
          @calendarView.alpha = 0
      end,
      completion: ->(finished) do
          @calendarHolder.removeFromSuperview
          @calendarView.delegate = nil
          @calendarView = nil
          @calendarHolder = nil
      end)
  end

  #only allow landscape if theyre on an iPad
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)

    if Device.iphone?
      interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown;
    else
      true
    end
  end

end #CrimeMapController