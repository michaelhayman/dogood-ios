@class DGGood;
@class DGPhotoPickerViewController;
@class DGFacebookManager;
@class DGTwitterManager;

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate> {
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
