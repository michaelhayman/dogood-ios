@class DGGood;
@class DGComment;
@class DGTextFieldSearchPeopleTableViewController;
@class DGTextFieldSearchTagsTableViewController;
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
    UITableView *searchTagsTable;
    DGTextFieldSearchPeopleTableViewController * searchPeopleTableController;
    DGTextFieldSearchTagsTableViewController * searchTagsTableController;
    NSString *searchTerm;

    NSMutableArray *entities;
}

typedef BOOL (^CheckEntitiesBlock)(BOOL end, NSMutableArray *entities);
- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(CheckEntitiesBlock)completion;
- (void)watchForEntities:(UITextView *)textField;
- (id)initWithTextView:(UITextView *)textView andEntities:(NSMutableArray *)inputEntities inController:(UIViewController *)controller withType:(NSString *)type;
- (void)resetTypingAttributes:(UITextView *)textField;
- (void)setLimitText;

@end
