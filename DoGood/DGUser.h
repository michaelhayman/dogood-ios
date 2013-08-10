@interface DGUser : NSObject

@property (retain) NSString *username;

#pragma mark - Class methods
+ (DGUser*)currentUser;

@end
