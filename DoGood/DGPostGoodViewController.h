@class DGGood;
@class DGPhotoPickerViewController;
@class DGFacebookManager;
@class DGTwitterManager;
@class DGEntityHandler;
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodNomineeViewController.h"
#import "DGPostGoodLocationViewController.h"
#import "DGPhotoPickerViewController.h"

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, DGPostGoodCategoryViewControllerDelegate, DGPostGoodLocationViewControllerDelegate, DGPhotoPickerViewControllerDelegate, DGPostGoodNomineeViewControllerDelegate> {
    UIActionSheet *nomineeSheet;
    UIActionSheet *categorySheet;
    UIActionSheet *locationSheet;
    UIImage *imageToUpload;
    __weak IBOutlet UIBarButtonItem *postButton;

    DGPhotoPickerViewController *photos;
    DGFacebookManager *facebookManager;
    DGTwitterManager *twitterManager;
}

@property (nonatomic, retain) DGGood *good;

- (IBAction)post:(id)sender;

@end

typedef enum {
    overview,
    nominee,
    category,
    location,
    share,
    numAgentListRows
} PostGoodRowType;
