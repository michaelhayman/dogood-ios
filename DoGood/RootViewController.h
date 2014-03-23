#import "REMenu.h"

@interface RootViewController : DGViewController

- (void)addMenuButton:(NSString *)menuButton withTapButton:(NSString *)tapButton;

@property (strong, nonatomic) REMenu *menu;

@end
