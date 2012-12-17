#import "CrimePin.h"

@implementation CrimePin

- (id)init: (NSMutableDictionary *) crime
{
    _crime = crime;
    _coordinate = CLLocationCoordinate2DMake([[_crime objectForKey:@"latitude"] floatValue], [[_crime objectForKey:@"longitude"] floatValue]);
    _type = [_crime objectForKey:@"type"];
    return self;
}

- (CLLocationCoordinate2D) coordinate
{
  return _coordinate;
}

//Return the offence locaton
-(NSString *) title {
    return [_crime objectForKey:@"location"];
}

//Return the date and the charge
-(NSString *) subtitle {
    return [NSString stringWithFormat:@"%@: %@", [self time], [_crime objectForKey:@"offense_charge"]];
}

//Return the date
-(NSString *) date {
    return [_crime objectForKey:@"date_day"];
}

-(NSString *) time {
    return [_crime objectForKey:@"date_time"];
}

-(NSString *) sortableTime {
    return [_crime objectForKey:@"timestamp"];
}

-(MKPinAnnotationColor) pinColor {
    if ([_type isEqualToString:@"Arrest"] ) {
        return MKPinAnnotationColorRed;
    } else {
        return MKPinAnnotationColorPurple;
    }
}

-(NSString *) pinImage {
    if ([_type isEqualToString:@"Arrest"] ) {
        return @"pinannotation_red";
    } else {
        return @"pinannotation_purple";
    }
}

-(NSString *)type {
    return [NSString stringWithFormat:@"%@", _type];
}

@end