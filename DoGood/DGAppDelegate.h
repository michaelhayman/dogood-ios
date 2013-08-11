/*
// Notification names:
static NSString * const kPAWFilterDistanceChangeNotification = @"kPAWFilterDistanceChangeNotification";
static NSString * const kPAWLocationChangeNotification = @"kPAWLocationChangeNotification";
static NSString * const kPAWPostCreatedNotification = @"kPAWPostCreatedNotification";
*/

@interface DGAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) NSArray *categories;

@end
