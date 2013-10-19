@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class GoodCell;

@interface DGEntityHandler : NSObject <UITextViewDelegate> {
    UIViewController *parent;

    __weak IBOutlet NSLayoutConstraint *commentFieldBottom;
    __weak IBOutlet UIView *commentInputView;
    // UITextView *commentInputField;
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

    // NSMutableArray *entities;
}

@property (nonatomic, weak) UITextView *commentInputField;

@property bool makeComment;
@property DGGood *good;
@property (nonatomic, retain) DGComment *comment;
@property (nonatomic, retain) GoodCell *goodCell;

- (void)initialize;

typedef BOOL (^CheckEntitiesBlock)(BOOL end, NSMutableArray *entities);
- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(CheckEntitiesBlock)completion;
// working kinda
// - (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(BOOL (^)(CheckEntitiesBlock))completion;

@end
