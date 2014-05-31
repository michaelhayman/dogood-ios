#import "DGExploreCategoriesViewController.h"
@class ExplorePopularTagsCell;
@class ExploreHighlightsCell;
@class SAMLoadingView;

@interface DGExploreCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *categories;
    
    __weak IBOutlet UITableView *tableView;
    SAMLoadingView *loadingView;

    ExploreHighlightsCell *exploreHighlights;
    ExplorePopularTagsCell *explorePopularTags;
    UIRefreshControl * refreshControl;
}

@end
