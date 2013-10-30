#import "DGCategory.h"
#import "constants.h"

@implementation DGCategory

- (UIImage *)image {
   NSString *iconName = [NSString stringWithFormat:@"category_%@.png", self.name_constant];
    return [UIImage imageNamed:iconName];
}

@end