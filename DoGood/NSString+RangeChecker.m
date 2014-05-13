#import "NSString+RangeChecker.h"

@implementation NSString (RangeChecker)

- (BOOL)containsRange:(NSRange)range {
    NSRange stringRange = NSMakeRange(0, [self length]);

    if (NSIntersectionRange(stringRange, range).length > 0) {
        return true;
    } else {
        return false;
    }
}

@end
