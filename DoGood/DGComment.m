#import "DGComment.h"
#import <NSDate+TimeAgo.h>

@implementation DGComment

- (NSString *)createdAgoInWords {
    return [self.created_at timeAgo];
}

- (NSString *)commentWithUsername {
    return [NSString stringWithFormat:@"%@ %@", self.user.username, self.comment];
}

@end
