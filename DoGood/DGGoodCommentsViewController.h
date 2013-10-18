#import "DGComment.h"
@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class GoodCell;

@interface DGGoodCommentsViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet NSLayoutConstraint *commentFieldBottom;
    __weak IBOutlet UIView *commentInputView;
    __weak IBOutlet UITextField *commentInputField;
    __weak IBOutlet UITableView *tableView;
    NSMutableArray *comments;
    __weak IBOutlet NSLayoutConstraint *tableViewBottom;
    __weak IBOutlet UIButton *sendButton;
    BOOL advanced;

    // keyboard
    CGFloat totalKeyboardHeight;
    UIToolbar *accessoryView;
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
