#import "DGCategory.h"
#import "DGAppearance.h"
#import "constants.h"

@implementation DGCategory

- (UIImage *)image {
   NSString *iconName = [NSString stringWithFormat:@"category_%@.png", self.name_constant];
    return [UIImage imageNamed:iconName];
}

- (UIColor *)rgbColour {
    if (self.colour != nil) {
        return [DGAppearance getColorFromHexValue:self.colour];
    } else {
        return [UIColor lightGrayColor];
    }
}

@end
