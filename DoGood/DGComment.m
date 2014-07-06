#import "DGComment.h"
#import <NSDate+TimeAgo.h>

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

@end
