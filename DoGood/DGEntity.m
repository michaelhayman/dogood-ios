#import "DGEntity.h"

@implementation DGEntity

- (NSRange)rangeFromArray {
    NSUInteger loc = [[self.range firstObject] intValue];
    NSUInteger len = [[self.range lastObject] intValue] - loc;
    return NSMakeRange(loc, len);
}

- (NSRange)rangeFromArrayWithOffset:(int)offset {
    NSUInteger loc = [[self.range firstObject] intValue];
    NSUInteger len = [[self.range lastObject] intValue] - loc;
    loc = loc + offset;
    return NSMakeRange(loc, len);
}

- (void)setArrayFromRange:(NSRange)range {
    self.range = [[NSArray alloc] initWithObjects:[NSNumber numberWithInt:range.location], [NSNumber numberWithInt:(range.length + range.location)], nil];
}

@end
