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
    return [NSString stringWithFormat:@"%@%@ %@", [self postedByType], self.user.full_name, [self createdAgoInWords]];
}

- (NSString *)postedByType {
    if ([self.done boolValue]) {
        return @"Nominated by ";
    } else {
        return @"Call for help by ";
    }
}

- (NSURL *)evidenceURL {
    return [NSURL URLWithString:self.evidence];
}

@end
