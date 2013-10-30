#import "DGCategory.h"
#import "constants.h"

@implementation DGCategory

- (NSString *)iconURL {
    return [NSString stringWithFormat:@"%@categories/%@.png", IMAGES_HOST_ADDRESS, self.name_constant];
}

- (UIImage *)image {
   NSString *iconName = [NSString stringWithFormat:@"category_%@.png", self.name_constant];
    return [UIImage imageNamed:iconName];
}

@end