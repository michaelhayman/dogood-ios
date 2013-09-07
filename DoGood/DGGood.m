#import "DGGood.h"
#import "FSLocation.h"
#import "DGCategory.h"

@implementation DGGood

- (void)setValuesForLocation:(FSLocation *)location {
    self.location_name = location.displayName;
    self.location_image = location.imageURL;
    self.lat = location.lat;
    self.lng = location.lng;
}

- (void)setValuesForCategory:(DGCategory *)category {
    self.category_id = category.categoryID;
}

@end
