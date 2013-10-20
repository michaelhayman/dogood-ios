#import "DGComment.h"
@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class GoodCell;
@class DGEntityHandler;

@interface DGGoodCommentsViewController : UIViewController <UITextViewDelegate> {
    __weak IBOutlet NSLayoutConstraint *commentFieldBottom;
    __weak IBOutlet UIView *commentInputView;
    __weak IBOutlet UITextView *commentInputField;
    __weak IBOutlet NSLayoutConstraint *commentInputFieldHeight;
    __weak IBOutlet NSLayoutConstraint *commentBoxHeight;

    __weak IBOutlet UITableView *tableView;
    NSMutableArray *comments;
    __weak IBOutlet NSLayoutConstraint *tableViewBottom;
    __weak IBOutlet UIButton *sendButton;

    // entities
    int characterLimit;
    CGFloat totalKeyboardHeight;
    NSMutableArray *entities;
    DGEntityHandler *entityHandler;
    UIView *loadingView;
    NSString *loadingStatus;
}

@property bool makeComment;
@property DGGood *good;
@property (nonatomic, retain) DGComment *comment;
@property (nonatomic, retain) GoodCell *goodCell;

@end
