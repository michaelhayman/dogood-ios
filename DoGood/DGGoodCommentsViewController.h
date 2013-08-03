#import <UIKit/UIKit.h>
#import "DGComment.h"
@class DGGood;
@class DGComment;

@interface DGGoodCommentsViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet NSLayoutConstraint *commentFieldBottom;
    __weak IBOutlet UIView *commentInputView;
    __weak IBOutlet UITextField *commentInputField;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *comments;
    __weak IBOutlet NSLayoutConstraint *tableViewBottom;
    __weak IBOutlet UIButton *sendButton;
}

@property bool makeComment;
@property DGGood *good;
@property (nonatomic, retain) DGComment *comment;

@end
