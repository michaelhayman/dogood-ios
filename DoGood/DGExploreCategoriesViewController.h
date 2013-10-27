#import "DGExploreCategoriesViewController.h"
@class ExplorePopularTagsCell;
@class ExploreHighlightsCell;

@interface DGExploreCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *categories;
    
    __weak IBOutlet UITableView *tableView;
    UIView *loadingView;

    ExploreHighlightsCell *exploreHighlights;
    ExplorePopularTagsCell *explorePopularTags;
}

@end
