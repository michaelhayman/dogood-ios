#import "DGGood+Dimensions.h"
#import "DGComment.h"

/**
 The central issue here is that these heights need to be static,
 since when they are needed the cell has not yet been called or created.
*/

@implementation DGGood (Dimensions)

#pragma mark - Height Calculations
- (CGFloat)captionWidth {
    if (iPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return 358.0;
        } else {
            return 614.0;
        }
    } else {
        return 236.0;
    }
}

- (CGFloat)commentBoxWidth {
    if (iPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return 343.0;
        } else {
            return 599.0;
        }
    } else {
        return 221.0;
    }
}

- (NSNumber *)calculateHeight {
    if (iPad) {
        return [self calculateWideHeight];
    } else {
        return [self calculateStandardHeight];
    }
}

- (NSNumber *)calculateWideHeight {
    CGFloat height = [[self calculateStandardHeight] floatValue];

    if (self.evidence) {
        height -= 320;
    }

    if (height < 340) {
        height = 355;
    }
    return [NSNumber numberWithFloat:height];
}

- (NSNumber *)calculateStandardHeight {
    CGFloat height = 90;

    NSDictionary *attributes = @{NSFontAttributeName : kGoodCaptionFont};

    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.caption attributes:attributes];

    CGFloat captionHeight = [DGAppearance calculateHeightForText:attrString andWidth:[self captionWidth]];
    height += captionHeight;

    NSAttributedString *postedByAttrString = [[NSAttributedString alloc] initWithString:[self postedByLine] attributes:attributes];
    CGFloat postedByHeight = [DGAppearance calculateHeightForText:postedByAttrString andWidth:[self captionWidth]];
    height += postedByHeight;

    if (self.evidence) {
        height+= 320;
    }
    if (self.location_name) {
        height += 20;
    }
    if (self.category) {
        height += 20;
    }
    if (self.comments) {
        height += 40;
        for (DGComment *comment in self.comments) {
            NSDictionary *commentAttributes = @{ NSFontAttributeName : kSummaryCommentFont };
            NSAttributedString *attrCommentString = [[NSAttributedString alloc] initWithString:[comment.user.full_name stringByAppendingString:comment.comment] attributes:commentAttributes];
            CGFloat commentHeight = [DGAppearance calculateHeightForText:attrCommentString andWidth:[self commentBoxWidth]];
            height += commentHeight;
        }
    }
    if ([self.votes_count intValue] > 0) {
        height += 30;
    }
    if ([self.followers_count intValue] > 0) {
        height += 30;
    }

    return [NSNumber numberWithFloat:height];
}

@end
