//
//  DGPostGoodViewController.h
//  DoGood
#import <UIKit/UIKit.h>
@class DGGood;

@interface DGPostGoodViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, UIActionSheetDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate> {
    UIActionSheet *categorySheet;
    UIActionSheet *locationSheet;
    UIActionSheet *photoSheet;
    UIImage *imageToUpload;
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
