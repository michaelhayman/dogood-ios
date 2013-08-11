#import "DGError.h"

@implementation DGError

- (NSString *)description {
    return [self.messages componentsJoinedByString:@"\n"];
}

@end

