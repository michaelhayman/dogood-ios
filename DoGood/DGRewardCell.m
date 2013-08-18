#import "DGRewardCell.h"
#import "DGReward.h"
#import <CODialog.h>

@implementation DGRewardCell

- (void)awakeFromNib {
    self.heading.preferredMaxLayoutWidth=100.0;
    self.subheading.preferredMaxLayoutWidth=100.0;

    // gestures
    UITapGestureRecognizer* headingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.heading setUserInteractionEnabled:YES];
    [self.heading addGestureRecognizer:headingGesture];

    UITapGestureRecognizer* subHeadingGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.subheading setUserInteractionEnabled:YES];
    [self.subheading addGestureRecognizer:subHeadingGesture];

    UITapGestureRecognizer* costGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.cost setUserInteractionEnabled:YES];
    [self.cost addGestureRecognizer:costGesture];

    UITapGestureRecognizer* teaserGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(options)];
    [self.teaser setUserInteractionEnabled:YES];
    [self.teaser addGestureRecognizer:teaserGesture];

    self.teaser.contentMode = UIViewContentModeScaleAspectFit;

    self.dialog = [CODialog dialogWithWindow:[[[UIApplication sharedApplication] delegate] window]];

}

- (void)setValues {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:self.reward.teaser] cachePolicy:NSURLRequestUseProtocolCachePolicy                                  timeoutInterval:15.0];
    [self.teaser setImageWithURLRequest:request placeholderImage:nil success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
        if (![self sufficientPoints] && [self.type isEqualToString:@"Rewards"]) {
            self.teaser.image = [self convertImageToGrayscale:image];
        } else {
            self.teaser.image = image;
        }
    } failure:nil];

    if (![self sufficientPoints] && [self.type isEqualToString:@"Rewards"]) {
        self.teaser.userInteractionEnabled = NO;
        self.heading.userInteractionEnabled = NO;
        self.heading.textColor = GRAYED_OUT;
        self.subheading.userInteractionEnabled = NO;
        self.subheading.textColor = GRAYED_OUT;
        self.cost.userInteractionEnabled = NO;
        self.cost.textColor = GRAYED_OUT;
    } else {
        self.heading.textColor = ACTIVE;
        self.teaser.userInteractionEnabled = YES;
        self.heading.userInteractionEnabled = YES;
        self.heading.textColor = ACTIVE;
        self.subheading.userInteractionEnabled = YES;
        self.subheading.textColor = ACTIVE;
        self.cost.userInteractionEnabled = YES;
        self.cost.textColor = ACTIVE;
    }

    self.heading.text = self.reward.title;
    self.subheading.text = self.reward.subtitle;
    self.cost.text = [NSString stringWithFormat:@"%@ points", self.reward.cost];

}

- (bool)sufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.reward.cost intValue];
}

#pragma mark - Options
- (void)options {
    if ([self.type isEqualToString:@"Rewards"]) {
        [self claim];
    } else {
        [self instructions];
    }
}

#pragma mark - Instructions dialog
- (void)instructions {
    [self.dialog resetLayout];
    self.dialog.title = self.heading.text;
    self.dialog.subtitle = @"instructions for obtaining this good should go here \nwhat if\n they're \n very \n long";
    self.dialog.dialogStyle = CODialogStyleCustomView;
    self.dialog.customView = nil;

    [self.dialog addButtonWithTitle:@"Got it" target:self selector:@selector(hideAndShow:)];
    [self.dialog showOrUpdateAnimated:YES];
}

#pragma mark - Claim dialog
- (void)claim {
    [self.dialog resetLayout];

    UIImageView *view = [[UIImageView alloc] init];
    [view setImageWithURL:[NSURL URLWithString:self.reward.teaser]];
    view.frame = CGRectMake(0, 0, 128, 128);
    view.contentMode = UIViewContentModeScaleAspectFit;

    self.dialog.title = self.heading.text;
    self.dialog.subtitle = [NSString stringWithFormat:@"%@\n%@ goods", self.subheading.text, self.reward.cost];
    self.dialog.dialogStyle = CODialogStyleCustomView;
    /*
    UIView *viewage = [[UIView alloc] init];
    viewage.frame = CGRectMake(0, 0, 128, 128);
    viewage = [self contentView];
    */
    self.dialog.customView = view;

    [self.dialog addButtonWithTitle:@"Nah" target:self selector:@selector(hideAndShow:)];
    [self.dialog addButtonWithTitle:@"Yes!" target:self selector:@selector(claimReward:) highlighted:YES];
    [self.dialog showOrUpdateAnimated:YES];
}

- (void)hideAndShow:(id)sender {
    [self.dialog hideAnimated:YES];
}

#pragma mark - Claim reward
- (void)claimReward:(id)sender {
    [self.dialog hideAnimated:YES];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:self.reward, @"reward", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserClaimRewardNotification object:nil userInfo:userInfo];
}

// credit:
// 
- (UIImage *)convertImageToGrayscale:(UIImage *)image {
    CGFloat actualWidth = image.size.width;
    CGFloat actualHeight = image.size.height;

    CGRect imageRect = CGRectMake(0, 0, actualWidth, actualHeight);
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceGray();

    CGContextRef context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, colorSpace, kCGImageAlphaNone);
    CGContextDrawImage(context, imageRect, [image CGImage]);

    CGImageRef grayImage = CGBitmapContextCreateImage(context);
    CGColorSpaceRelease(colorSpace);
    CGContextRelease(context);

    context = CGBitmapContextCreate(nil, actualWidth, actualHeight, 8, 0, nil, kCGImageAlphaOnly);
    CGContextDrawImage(context, imageRect, [image CGImage]);
    CGImageRef mask = CGBitmapContextCreateImage(context);
    CGContextRelease(context);

    UIImage *grayScaleImage = [UIImage imageWithCGImage:CGImageCreateWithMask(grayImage, mask) scale:image.scale orientation:image.imageOrientation];
    CGImageRelease(grayImage);
    CGImageRelease(mask);
    return grayScaleImage;
}

@end
