#import "DGActionButton.h"

@implementation DGActionButton

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];

    if (self) {
        UIImage *on = [[UIImage imageNamed:@"bt_lrg_off"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 6)];
        UIImage *off = [[UIImage imageNamed:@"bt_lrg_on"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 11, 0, 6)];
        [self setBackgroundImage:on forState:UIControlStateNormal];
        [self setBackgroundImage:off forState:UIControlStateHighlighted];
        self.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    }
    return self;
}

@end
