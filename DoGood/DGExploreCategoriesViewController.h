#import "DGExploreCategoriesViewController.h"
@class ExplorePopularTagsCell;
@class ExploreHighlightsCell;
@class SAMLoadingView;

@interface DGExploreCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) UIRefreshControl *refreshControl;
@property (nonatomic, strong) NSArray *categories;
    
@property (nonatomic, strong) SAMLoadingView *loadingView;

@property (nonatomic, strong) ExploreHighlightsCell *exploreHighlights;
@property (nonatomic, strong) ExplorePopularTagsCell *explorePopularTags;

@end
