#import "DGGood.h"
#import "FSLocation.h"

@implementation DGGood

- (void)setValuesForLocation:(FSLocation *)location {
    self.locationName = location.displayName;
    self.lat = location.lat;
    self.lng = location.lng;
}

@end
