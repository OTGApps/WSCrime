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