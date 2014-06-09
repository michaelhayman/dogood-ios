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

- (BOOL)containsString:(NSString *)string {
    NSCharacterSet *cset = [NSCharacterSet characterSetWithCharactersInString:string];
    NSRange range = [self rangeOfCharacterFromSet:cset];
    if (range.location == NSNotFound) {
        return NO;
    } else {
        return YES;
    }
}

@end
