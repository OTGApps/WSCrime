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

class MapController < UIViewController

  include BW::Reactor

  #Constants
  MetersPerMile = 1609.344
  AnimationTime = 0.25

  def viewDidLoad

    mapView = MKMapView.alloc.initWithFrame(CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height))
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    self.view = mapView
    view.delegate = self

    #Init instance values
    @didInitialZoom = false
    @didInitialPinZoom = false
    @theDate = NSDate.date

  	#Set the application title
    self.setTitle("Crime Map", subtitle:"Winston-Salem, NC")

    #Setup the toolbar and navigationbar
    self.navigationController.setToolbarHidden(false)
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    self.navigationController.toolbar.barStyle = UIBarStyleBlack;

    #Create buttons
    reZoomButton = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("location"),
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: "rezoom:")
    self.navigationItem.rightBarButtonItem = reZoomButton

    listButton = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("magnify"),
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: "showDetail:")
    self.navigationItem.leftBarButtonItem = listButton

    aboutButton = UIBarButtonItem.alloc.initWithTitle(
      "About",
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: "loadAboutWindow:")

    arButton = UIBarButtonItem.alloc.initWithImage(
      UIImage.imageNamed("radar"),
      style: UIBarButtonItemStyleBordered,
      target: self,
      action: "loadARWindow:")

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

    if ARKit.deviceSupportsAR || Device.simulator?
      self.toolbarItems = [aboutButton, arButton, flexibleSpace, @activityViewButton, @dateButton]
    else
      self.toolbarItems = [aboutButton, flexibleSpace, @activityViewButton, @dateButton]
    end

    #Send a request off to the server to get the data.
    loadData
  end

  def viewDidAppear(animated)
    # Show the about window if this is their first time loading the app.
    seenAbout = App::Persistence['seenAbout']
    unless seenAbout == "yes"
      loadAboutWindow(nil)
    end

    self.navigationController.setToolbarHidden(false, animated:true)

  end

  def viewWillAppear(animated)

    #Check to see if we've loaded the view into Winston-Salem yet
    if @didInitialZoom == false

      #Center on Winston-Salem.
      initialLocation = CLLocationCoordinate2D.new(36.10, -80.26)
      region = MKCoordinateRegionMakeWithDistance(initialLocation, 4 * MetersPerMile, 4 * MetersPerMile)
      self.view.setRegion(region, animated:true)

      @didInitialZoom = true
    else
      puts "Initial zoom already done."
    end
  end

  #This method loads the data from my server and sets the data into the map annotations
  def loadData
    @dateButton.title = "Loading data..."
    @activityView.startAnimating

    #Find the date to use
    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")
    dateString = dateFormat.stringFromDate(@theDate)

    CrimeAPI.dataForDate(dateString) do |json, error|
      ap "got results"

      if error == nil

          removeAllAnnotations
          if json.count > 0

            annotations = []
            json.each do |crimeData|
                annotations << CrimeAnnotation.new(crimeData)
            end

            self.view.addAnnotations(annotations)
            dateAndZoom

          else

            App.alert("No Results Found for that day.")
            @activityView.stopAnimating
            @dateButton.title = "No Results"

          end
      else

        App.alert("Whoops! There was an error downloading data from the server. Please check your internet connection or try again later.")
        @dateButton.title = "Server Error"
        @activityView.stopAnimating

      end

    end # CrimeAPI block
  end

  def removeAllAnnotations
    annotations.each do |thisAnnotation|
      self.view.removeAnnotation(thisAnnotation)
    end
  end

  def dateAndZoom
    p "Checking the date of the annotations and zooming appropriately."

    @dateButton.title = @theDate.to_s
    @activityView.stopAnimating

    #Get the first crime so we can make sure @theDate is set correctly for our data
    firstAnnotation = annotations[0]

    dateFormat = NSDateFormatter.alloc.init
    dateFormat.setDateFormat("yyyy-MM-dd")

    @theDate = dateFormat.dateFromString(firstAnnotation.date)
    newDate = NSDate.dateWithTimeInterval(0, sinceDate:@theDate)

    dateFormat.setDateFormat("MMM dd, yyyy")
    theNewDate = dateFormat.stringFromDate(@theDate)

    @dateButton.title = theNewDate

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
    return if annotations.length == 0

    #Set some boundaries
    topLeftCoord = CLLocationCoordinate2DMake(-90, 180)
    bottomRightCoord = CLLocationCoordinate2DMake(90, -180)

    #Find the bounds of the pins
    annotations.each do |crime|
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
    fits = self.view.regionThatFits(region);

    self.view.setRegion(fits, animated:true)
  end

  #Present the about window in a modal view.
  def loadAboutWindow(sender)

    App::Persistence['seenAbout'] = "yes"

    aboutNavController = PortraitNavigationController.alloc.initWithRootViewController AboutController.new
    aboutNavController.setModalPresentationStyle(UIModalPresentationFormSheet)

    self.navigationController.presentModalViewController(aboutNavController, animated:true)
  end

  def showDetail(sender)

    if annotations.length == 0
        App.alert("There are no incidents to view.")
        return
    end

    detailViewController = DetailController.alloc.initWithData( annotations.mutableCopy, date:@dateButton.title )
    detailViewController.parentVC = self
    detailNavController = PortraitNavigationController.alloc.initWithRootViewController(detailViewController)
    detailNavController.setModalTransitionStyle(UIModalTransitionStyleFlipHorizontal)
    detailNavController.setModalPresentationStyle(UIModalPresentationFormSheet)

    self.navigationController.presentModalViewController(detailNavController, animated:true)
  end

  def closeDetailAndZoomToEvent(marker)
    self.navigationController.dismissModalViewControllerAnimated(true)

    # Close all the annotations just in case
    unless self.view.selectedAnnotations.nil?
      self.view.selectedAnnotations.each do |annotation|
        self.view.deselectAnnotation(annotation, animated:false)
      end
    end

    EM.add_timer 0.75 do
      zoomToAndSelectMarker marker
    end

  end

  def zoomToAndSelectMarker(marker)
    region = MKCoordinateRegionMake( marker.coordinate, MKCoordinateSpanMake( 0.05, 0.05 ) )
    self.view.setRegion(region, animated:true)
    self.view.selectAnnotation(marker, animated:true)
  end

  #Present the calendar view to change the date.
  def changeDate(sender)
    puts "Changing the date"

    #Show the calendar.
    if @calendarHolder != nil
      destroyCalendar
      return
    end

    @calendarHolder = UIView.alloc.initWithFrame(self.view.frame)
    @calendarView = CKCalendarView.alloc.initWithStartDay(1)
    @calendarView.delegate = self
    @calendarView.selectedDate = @theDate

    #Position the calendar view
    screenBounds = self.view.bounds
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
    @calendarView.setCenter(self.view.center)

    @calendarHolder.addSubview(@calendarView)

    @calendarHolder.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight
    @calendarHolder.alpha = 0
    @calendarView.alpha = 0
    @calendarHolder.backgroundColor = UIColor.colorWithWhite(0, alpha:0.5)

    self.view.addSubview(@calendarHolder)

    UIView.animateWithDuration(AnimationTime,
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
    #p "Selecting date: " + date.to_s

    if @theDate.isEqualToDate(date) == false

      if date.laterDate(Time.now) == date
        App.alert("Please select a date\nin the past.")
        return;
      end

      @theDate = date
      loadData
    end

    destroyCalendar
  end

  #Goodbye, calendar!
  def destroyCalendar
    UIView.animateWithDuration(AnimationTime,
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

  def annotations
    self.view.annotations || []
  end


  # Augmented Reality

  def loadARWindow(sender)

    if annotations.length == 0
        App.alert("There are no incidents to view.")
        return
    end

    if ARKit.deviceSupportsAR || Device.simulator?

        arVC = ARViewController.alloc.initWithDelegate( self )
        arVC.setRadarRange(4000.0)
        arVC.setOnlyShowItemsWithinRadarRange(true)
        arVC.showsCloseButton = false
        arVC.setHidesBottomBarWhenPushed(true)
        arVC.setRotateViewsBasedOnPerspective(false)

        self.navigationController.pushViewController(arVC, animated:true)

    end
  end

  def geoLocations

    locationArray = []

     annotations.each do |thisAnnotation|
       locationArray << ARGeoCoordinate.coordinateWithLocation(thisAnnotation.cllocation, locationTitle:thisAnnotation.offense)
     end

    locationArray
  end

  def locationClicked(coordinate)
    puts coordinate
  end

end #MapController
