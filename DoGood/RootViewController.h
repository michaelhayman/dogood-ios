#import "REMenu.h"

@interface RootViewController : UIViewController

- (void)addMenuButton:(NSString *)menuButton withTapButton:(NSString *)tapButton;

@property (strong, nonatomic) REMenu *menu;

@end
