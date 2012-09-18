class CrimeMapController < UIViewController

  def viewDidLoad

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
  	#self.title = "Winston-Salem Crime Map"
    self.setTitle("Crime Map", subtitle:"Winston-Salem, NC")
    
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
      "Loading data...",
       style: UIBarButtonItemStyleBordered,
       target: self,
       action: "changeDate:")
    
    self.toolbarItems = [buttonItem1, flexibleSpace, @activityViewButton, @dateButton]

    #Send a request off to the server to get the data.
    loadData
  end

  def viewDidAppear(animated)
    # Show the about window if this is their first time loading the app.
    seenAbout = App::Persistence['seenAbout']
    unless seenAbout == "yes"
      loadAboutWindow(nil)
    end
  end

  def viewWillAppear(animated)
    
    #Check to see if we've loaded the view into Winston-Salem yet
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

  #This method loads the data from my server and sets the data into the @thePoints var
  def loadData
    @dateButton.title = "Loading data..."
    @activityView.startAnimating

    #Find the date to use
    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")
    dateString = dateFormat.stringFromDate(@theDate)

    BubbleWrap::HTTP.get("http://crimestats.mohawkapps.com/nc/winston-salem/?date=" + dateString) do |response|
        if response.ok?

          json = BubbleWrap::JSON.parse(response.body.to_str)

          if json.count > 0
            @thePoints.removeAllObjects

            json.each do |crimeData|
              @thePoints.push(CrimeAnnotation.new(crimeData, crimeData['type']))
            end

            #Re-layout all the data on the mapView
            replot

          else
            App.alert("No Results Found for that day.")
            @activityView.stopAnimating
            @dateButton.title = "No Results"
            removeAllAnnotations
          end

          #p @thePoints

        else
          App.alert("Whoops! There was an error downloading data from the server. Please check your internet connection or try again later.")
          @activityView.stopAnimating
          @dateButton.title = "Server Error"
        end
    end

  end

  def removeAllAnnotations
    @mapView.annotations.each do |thisAnnotation|
      @mapView.removeAnnotation(thisAnnotation)
    end
  end

  def replot
    p "Replotting"

    @dateButton.title = @theDate.to_s
    @activityView.stopAnimating

    removeAllAnnotations

    #Get the first crime so we can make sure @theDate is set correctly for our data
    firstAnnotation = @thePoints[0]

    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")

    @theDate = dateFormat.dateFromString(firstAnnotation.date)
    newDate = NSDate.dateWithTimeInterval(0, sinceDate:@theDate)

    dateFormat.setDateFormat("MMM dd, yyyy")
    theNewDate = dateFormat.stringFromDate(@theDate)

    @dateButton.title = theNewDate

    #Add the points to the map
    p @thePoints.count
    @thePoints.each do |crime|
      @mapView.addAnnotation(crime)
    end

    #Only change the map zoom if this is the first data load.
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
      #Set the pin properties
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
      return
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

    #Find the bounds of all the pins and set the mapView 
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

  #Present the about window in a moval view.
  def loadAboutWindow(sender)

    App::Persistence['seenAbout'] = "yes"

    aboutViewController = AboutController.alloc.init
    aboutNavController = UINavigationController.alloc.initWithRootViewController(aboutViewController)
    aboutNavController.setModalPresentationStyle(UIModalPresentationFormSheet)

    self.navigationController.presentModalViewController(aboutNavController, animated:true)
  end

  #Present the calendar view to change the date.
  def changeDate(sender)
    puts "Changing the date"

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

  #CKCalendarView delegate method for when a date is tapped
  def calendar(calendar, didSelectDate:date)
    p "Selecting date: " + date.to_s

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

  #Goodbye, calendar!
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

  #only allow landscape if they're on an iPad
  def shouldAutorotateToInterfaceOrientation(interfaceOrientation)
    if Device.iphone?
      interfaceOrientation == UIInterfaceOrientationPortrait || interfaceOrientation == UIInterfaceOrientationPortraitUpsideDown
    else
      true
    end
  end
  def supportedInterfaceOrientations
    if Device.iphone?
      UIInterfaceOrientationMaskPortrait | UIInterfaceOrientationMaskPortraitUpsideDown
    else
      UIInterfaceOrientationMaskAll
    end
  end

end #CrimeMapController