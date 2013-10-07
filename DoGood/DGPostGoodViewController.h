@class DGGood;

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIActionSheet *categorySheet;
    UIActionSheet *locationSheet;
    UIActionSheet *photoSheet;
    UIImage *imageToUpload;
    __weak IBOutlet UIBarButtonItem *postButton;
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
