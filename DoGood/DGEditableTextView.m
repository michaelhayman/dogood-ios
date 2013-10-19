#import "DGEditableTextView.h"
#import "constants.h"
#import <QuartzCore/QuartzCore.h>

@implementation DGEditableTextView

- (void)layoutSubviews {
	[super layoutSubviews];
	self.layer.borderWidth = 1.0;
    self.layer.borderColor = TEXT_VIEW_BORDER_COLOR.CGColor;
}

@end