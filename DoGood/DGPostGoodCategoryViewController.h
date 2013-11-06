@protocol DGPostGoodCategoryViewControllerDelegate;
@class DGCategory;

@interface DGPostGoodCategoryViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource> {
    NSArray *categories;
}

@property (nonatomic, weak) id<DGPostGoodCategoryViewControllerDelegate> delegate;

@end

@protocol DGPostGoodCategoryViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodCategoryViewController* )viewController
    didChooseCategory:(DGCategory *)category;

@end
