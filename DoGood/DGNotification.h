@interface DGNotification : NSObject

+ (void)promptForNotifications;
+ (void)reregisterForNotifications;
+ (void)registerToken:(NSData *)token;
+ (void)handleNotification:(NSDictionary *)userInfo;
+ (void)setNotifiable;

@end
