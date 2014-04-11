#import "DGCategory.h"
#import "constants.h"

@implementation DGCategory

- (UIImage *)image {
    NSString *iconName = [NSString stringWithFormat:@"icon_menu_%@.png", self.name_constant];
    return [UIImage imageNamed:iconName];
}

- (UIImage *)contentIcon {
    NSString *iconName = [NSString stringWithFormat:@"icon_content_%@", self.name_constant];
    UIImage *image = [UIImage imageNamed:iconName];
    if (!image) {
        image = [UIImage imageNamed:@"CategoryIconOn"];
    }
    return image;
}

- (UIColor *)rgbColour {
    if (self.colour != nil) {
        return [DGAppearance getColorFromHexValue:self.colour];
    } else {
        return [UIColor lightGrayColor];
    }
}

@end
