@interface NSString (RangeChecker)

- (BOOL)containsRange:(NSRange)range;
- (BOOL)containsString:(NSString *)string;

@end
