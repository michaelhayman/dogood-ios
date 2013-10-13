#import "DGTag.h"

@implementation DGTag

- (NSString *)hashifiedName {
    return [NSString stringWithFormat:@"#%@", self.name];
}

@end
