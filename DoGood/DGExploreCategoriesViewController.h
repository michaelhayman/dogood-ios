#import "DGExploreCategoriesViewController.h"
@class ExplorePopularTagsCell;
@class ExploreHighlightsCell;
@class DGLoadingView;

@interface DGExploreCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *categories;
    
    __weak IBOutlet UITableView *tableView;
    DGLoadingView *loadingView;

    ExploreHighlightsCell *exploreHighlights;
    ExplorePopularTagsCell *explorePopularTags;
}

@end
