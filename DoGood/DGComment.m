#import "DGComment.h"
#import "DGGood.h"
#import <NSDate+TimeAgo.h>

static NSString * const kCommentsURL = @"/comments";

@implementation DGComment

- (NSString *)createdAgoInWords {
    return [self.created_at timeAgo];
}

- (NSString *)commentWithUsername {
    return [NSString stringWithFormat:@"%@ %@", self.user.full_name, self.comment];
}

- (CGFloat)commentBoxWidth {
    if (iPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return 696.0;
        } else {
            return 952.0;
        }
    } else {
        return 248.0;
    }
}

+ (void)getCommentsForGood:(DGGood *)good page:(NSInteger)page completion:(RetrieveCommentsBlock)completion {
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:NSNullIfNil([NSNumber numberWithInteger:page]), @"page", NSNullIfNil(good.goodID), @"good_id", nil];

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/comments" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        completion(mappingResult.array, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

+ (void)postComment:(DGComment *)comment completion:(ManageCommentBlock)completion {
    [[RKObjectManager sharedManager] postObject:comment path:kCommentsURL parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        DGComment *comment = [mappingResult.array firstObject];
        completion(comment, nil);
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        completion(nil, error);
    }];
}

@end
