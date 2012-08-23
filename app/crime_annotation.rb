class CrimeAnnotation

  #Creates the new crime object
  def initialize(crime, type)
    @crime = crime
   	@coordinate = CLLocationCoordinate2D.new
    @type = type
  end

  #Return the offence locaton
  def title
    @crime['location']
  end

  #Return the date and the charge
  def subtitle
    time + ": " + @crime['offense_charge']
  end
  
  #Return the date
  def date
    @crime['date_day']
  end
  
  def time
    @crime['date_time']
  end
  
  def coordinate
    @coordinate.latitude = @crime['latitude']
    @coordinate.longitude = @crime['longitude']
    
    @coordinate
  end

  def pinColor
    if @type == "Arrest"
      MKPinAnnotationColorRed
    else
      MKPinAnnotationColorPurple
    end
  end

  def type; @type; end
  
end