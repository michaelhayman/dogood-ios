typedef BOOL (^openURLBlock)(BOOL matched);

@interface URLHandler : NSObject

- (void)openURL:(NSURL *)url andReturn:(openURLBlock)match;

@end
