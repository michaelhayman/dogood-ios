#import "DGComment.h"
@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class GoodCell;

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
    BOOL advanced;

    // keyboard
    CGFloat totalKeyboardHeight;
    UIToolbar *accessoryView;
    NSLayoutConstraint *accessoryViewHeight;
    UIButton *accessoryButtonMention;
    UIButton *accessoryButtonTag;
    UILabel *characterLimitLabel;
    int characterLimit;

    bool searchPeople;
    bool searchTags;

    int startOfRange;
    UITableView *searchTable;

    NSString *searchTerm;
    DGTextFieldSearchPeopleTableViewController * searchPeopleTableController;

    NSMutableArray *entities;
}

@property bool makeComment;
@property DGGood *good;
@property (nonatomic, retain) DGComment *comment;
@property (nonatomic, retain) GoodCell *goodCell;

@end
