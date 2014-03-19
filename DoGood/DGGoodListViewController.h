#import "RootViewController.h"
@class DGCategory;
@class UserOverview;
@class DGTag;
@class DGGood;
@class GoodTableView;

@interface DGGoodListViewController : RootViewController {
    UserOverview *userView;
    __weak IBOutlet GoodTableView *goodTableView;
}

@property (nonatomic, copy) NSString *path;
@property (nonatomic, strong) NSString *titleForPath;
@property (nonatomic, strong) DGCategory *category;
@property (nonatomic, strong) DGTag *tag;
@property (nonatomic, strong) NSNumber *goodID;

- (void)getGood;

@end
