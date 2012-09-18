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

  def sortableTime
    t = time.split(" ").first
    ap = time.split(" ").last

    if ap == "pm"
      parts = t.split(":")
      hour = parts.first.to_i + 12
      t = hour.to_s + parts.last
    else
      t = t.split(":").join("")
    end
    t.to_i
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

  def pinImage
    if @type == "Arrest"
      "pinannotation_red"
    else
      "pinannotation_purple"
    end
  end

  def type; @type; end
  
end