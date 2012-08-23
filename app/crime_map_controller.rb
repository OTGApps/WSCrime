class CrimeMapController < UIViewController

  def loadView
  	self.view = MKMapView.alloc.init
    view.delegate = self
  end

  def viewDidLoad
    super

    #Init instance values
    @didInitialZoom = false
    @didInitialPinZoom = false
    @theDate = NSDate.date
    @thePoints = NSMutableArray.alloc.init

    #view.frame = self.view.frame

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
      self.view.setRegion(region, animated:true)

      @didInitialZoom = true
    else
      puts "Initial zoom already done."
    end

  end    

  def loadData

    #Find the date to use
    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")
    dateString = dateFormat.stringFromDate(@theDate)

    BubbleWrap::HTTP.get("http://crimestats.mohawkapps.com/nc/winston-salem/?date=" + dateString) do |response|
        if response.ok?
          p response.body.to_str

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

    self.view.annotations.each do |thisAnnotation|
      self.view.removeAnnotation(thisAnnotation)
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
      self.view.addAnnotation(crime)
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
    if self.view.annotations.count == 0
      false
    end

    #Set some boundaries
    topLeftCoord = CLLocationCoordinate2DMake(-90, 180)
    bottomRightCoord = CLLocationCoordinate2DMake(90, -180)

    #Find the bounds of the pins
    self.view.annotations.each do |crime|
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
    fits = self.view.regionThatFits(region);
    self.view.setRegion(fits, animated:true)
  end

  def loadAboutWindow(sender)
    aboutNavController = UINavigationController.alloc.initWithRootViewController(AboutController.alloc.init)
    self.navigationController.presentModalViewController(aboutNavController, animated:true)
  end

  def changeDate(sender)
    puts "Change the date"
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