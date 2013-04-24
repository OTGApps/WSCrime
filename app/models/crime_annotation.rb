class CrimeAnnotation

  attr_accessor :type

  #Creates the new crime object
  def initialize(crime)
    @crime = crime
    @type = @crime['type']
    @coordinate = CLLocationCoordinate2DMake(@crime['latitude'], @crime['longitude'])
  end

  #Return the offence locaton
  def title
    @crime['location']
  end

  #Return the date and the charge
  def subtitle
    time + ": " + offense
  end

  def offense
    @crime['offense_charge']
  end

  #Return the date
  def date
    @crime['date_day']
  end

  def time
    @crime['date_time']
  end

  def sortableTime
    @crime['timestamp']
  end

  def coordinate
    @coordinate
  end

  def cllocation
    CLLocation.alloc.initWithLatitude(@crime['latitude'], longitude:@crime['longitude'])
  end

  def pinColor
    if @type == "Arrest"
      MKPinAnnotationColorRed
    else
      MKPinAnnotationColorPurple
    end
  end

  def pinImage
    if @type == "Arrest"
      "pinannotation_red"
    else
      "pinannotation_purple"
    end
  end

  def setCoordinate(newCoordinate);
    @coordinate = newCoordinate
  end

end
