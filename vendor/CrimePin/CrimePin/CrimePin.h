#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface CrimePin : NSObject<MKAnnotation>
{
    CLLocationCoordinate2D _coordinate;
    NSMutableDictionary* _crime;
    NSString* _type;
}

- (id)init: (NSMutableDictionary *) crime;
- (NSString *) type;
@property (nonatomic, readonly) CLLocationCoordinate2D coordinate;

@end