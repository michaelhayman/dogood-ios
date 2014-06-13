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

- (BOOL)isOwnGood {
    if ([[DGUser currentUser].userID isEqualToNumber:self.user.userID]) {
        return YES;
    } else {
        return NO;
    }
}

- (void)destroyGoodWithCompletion:(DestroyCompletionBlock)complete {
    [[RKObjectManager sharedManager] deleteObject:self path:[NSString stringWithFormat:@"/goods/%@", self.goodID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        complete(YES, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        complete(NO, error);
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (NSURL *)showURL {
    return [NSURL URLWithString:[NSString stringWithFormat:@"dogood://goods/%@", self.goodID]];
}

@end
