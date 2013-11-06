@class DGGood;
@class DGPhotoPickerViewController;
@class DGFacebookManager;
@class DGTwitterManager;
@class DGEntityHandler;
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodLocationViewController.h"

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, DGPostGoodCategoryViewControllerDelegate, DGPostGoodLocationViewControllerDelegate> {
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
    category,
    location,
    who,
    share,
    numAgentListRows
} PostGoodRowType;
