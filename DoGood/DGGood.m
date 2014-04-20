#import "DGGood.h"
#import "FSLocation.h"
#import "DGCategory.h"
#import <NSDate+TimeAgo.h>

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

- (NSString *)createdAgoInWords {
    return [self.created_at timeAgo];
}

- (NSString *)postedByLine {
    return [NSString stringWithFormat:@"By %@ %@", self.user.full_name, [self  createdAgoInWords]];
}

- (NSURL *)evidenceURL {
    return [NSURL URLWithString:self.evidence];
}

@end
