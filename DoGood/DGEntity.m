#import "DGEntity.h"

@implementation DGEntity

- (NSRange)rangeFromArray {
    NSInteger loc = [[self.range firstObject] intValue];
    NSInteger len = [[self.range lastObject] intValue];
    return NSMakeRange(loc, len);
}

- (NSRange)rangeFromArrayWithOffset:(NSInteger)offset {
    NSInteger loc = [[self.range firstObject] intValue];
    loc += offset;
    NSInteger len = [[self.range lastObject] intValue];
    return NSMakeRange(loc, len);
}

- (void)setArrayFromRange:(NSRange)range {
    self.range = [[NSArray alloc] initWithObjects:[NSNumber numberWithInteger:range.location], [NSNumber numberWithInteger:(range.length)], nil];
}

static inline  NSRegularExpression * HashRegularExpression() {
    static NSRegularExpression *_HashRegularExpression = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _HashRegularExpression = [[NSRegularExpression alloc] initWithPattern:@"#[A-Za-z0-9_]+" options:NSRegularExpressionCaseInsensitive error:nil];
    });
    return _HashRegularExpression;
}

+ (void)findTagEntitiesIn:(NSString *)string forLinkID:(NSNumber *)linkID completion:(HashSearchCompletionBlock)completion {
    NSRange stringRange = NSMakeRange(0, [string length]);
    NSRegularExpression *regexp = HashRegularExpression();
    NSMutableArray *entities = [[NSMutableArray alloc] init];
    [regexp enumerateMatchesInString:string options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {
        DGEntity *entity = [[DGEntity alloc] init];
        [entity setArrayFromRange:result.range];
        entity.link_id = linkID;
        entity.link_type = @"tag";
        entity.title = [string substringWithRange:result.range];
        [entities addObject:entity];
        completion(entities, nil);
    }];
}

@end
