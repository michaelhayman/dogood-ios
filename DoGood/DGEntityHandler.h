@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class GoodCell;

@interface DGEntityHandler : NSObject <UITextViewDelegate> {
    UIViewController *parent;

    UITextView *entityTextView;
    NSString *entityType;

    // keyboard
    UIToolbar *accessoryView;
    UIButton *accessoryButtonMention;
    UIButton *accessoryButtonTag;
    UILabel *characterLimitLabel;
    int characterLimit;
    CGFloat totalKeyboardHeight;

    // searching
    bool searchPeople;
    bool searchTags;
    int startOfRange;

    UITableView *searchTable;
    DGTextFieldSearchPeopleTableViewController * searchPeopleTableController;
    NSString *searchTerm;

    NSMutableArray *entities;
}

@property (nonatomic, weak) UITextView *commentInputField;

typedef BOOL (^CheckEntitiesBlock)(BOOL end, NSMutableArray *entities);
- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(CheckEntitiesBlock)completion;
- (void)watchForEntities:(UITextView *)textField;
- (id)initWithTextView:(UITextView *)textView andEntities:(NSMutableArray *)inputEntities inController:(UIViewController *)controller withType:(NSString *)type;
- (void)resetTypingAttributes:(UITextView *)textField;
- (void)setLimitText;

@end
