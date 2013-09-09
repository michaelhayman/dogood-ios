#import "DGExploreCategoriesViewController.h"

@interface DGExploreCategoriesViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *categories;
    
    __weak IBOutlet UITableView *tableView;
}

@end
