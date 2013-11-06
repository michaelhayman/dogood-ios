#import "DGExploreSearchViewController.h"
@class DGExploreSearchPeopleTableViewController;
@class DGExploreSearchTagsTableViewController;
@class DGExploreViewController;

@interface DGExploreSearchViewController : UIViewController <UITextFieldDelegate, UIScrollViewDelegate> {
    // buttons
    __weak IBOutlet UIView *headerView;
    __weak IBOutlet NSLayoutConstraint *headerViewToTopConstraint;
    __weak IBOutlet UIButton *tagsButton;
    __weak IBOutlet UIButton *peopleButton;

    // tables
    __weak IBOutlet UITableView *tableView;
    DGExploreSearchPeopleTableViewController *searchPeopleTable;
    DGExploreSearchTagsTableViewController *searchTagsTable;

    // kb
    UITapGestureRecognizer *dismissTap;

}

@property (nonatomic, weak) DGExploreViewController* parent;
@property (nonatomic, weak) UITextField* searchField;

@end
