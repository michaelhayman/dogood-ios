@class DGGood;
@class DGPhotoPickerViewController;
@class DGFacebookManager;
@class DGTwitterManager;
@class DGEntityHandler;
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodNomineeSearchViewController.h"
#import "DGPostGoodLocationViewController.h"
#import "DGPhotoPickerViewController.h"

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, DGPostGoodCategoryViewControllerDelegate, DGPostGoodLocationViewControllerDelegate, DGPhotoPickerViewControllerDelegate, DGPostGoodNomineeViewControllerDelegate> {
    UISegmentedControl *tabControl;

    UIActionSheet *nomineeSheet;
    UIActionSheet *categorySheet;
    UIActionSheet *locationSheet;
    UIImage *imageToUpload;
    __weak IBOutlet UIBarButtonItem *postButton;

    DGPhotoPickerViewController *photos;
    DGFacebookManager *facebookManager;
    DGTwitterManager *twitterManager;
    DGPostGoodNomineeSearchViewController *nomineeController;
}

@property (nonatomic, retain) DGGood *good;
@property (nonatomic, retain) DGCategory *category;
@property int doneGoods;

- (IBAction)post:(id)sender;

@end

typedef enum {
    overview,
    nominee,
    category,
    location,
    share,
    numPostGoodRows
} PostGoodRowType;

typedef enum {
    // facebook,
    twitter,
    numShareRows
} PostGoodShareType;