#import "RootViewController.h"
@class DGCategory;
@class UserOverview;
@class DGTag;
@class DGGood;
@class DGLoadingView;
@class GoodTableView;

@interface DGGoodListViewController : RootViewController {
    UserOverview *userView;
    __weak IBOutlet GoodTableView *goodTableView;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSString *titleForPath;
@property (nonatomic, weak) DGCategory *category;
@property (nonatomic, weak) DGTag *tag;
@property (nonatomic, strong) NSNumber *goodID;

- (void)showWelcome;
- (void)getGood;

@end
