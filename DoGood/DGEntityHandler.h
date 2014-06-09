@class DGTextFieldSearchPeopleTableViewController;
@class DGTextFieldSearchTagsTableViewController;

@interface DGEntityHandler : NSObject <UITextViewDelegate> {
    __weak UIViewController *parent;

    __weak UITextView *entityTextView;
    NSString *entityType;
    NSNumber *linkID;

    // keyboard
    UIInputView *accessoryView;
    UIButton *accessoryButtonMention;
    UIButton *accessoryButtonTag;
    UILabel *characterLimitLabel;
    int characterLimit;
    int tableOffset;
    int secondTableOffset;
    CGFloat totalKeyboardHeight;

    // searching
    bool searchPeople;
    bool searchTags;
    NSInteger startOfRange;

    BOOL reverseScroll;

    UITableView *searchTable;
    UITableView *searchTagsTable;
    DGTextFieldSearchPeopleTableViewController * searchPeopleTableController;
    DGTextFieldSearchTagsTableViewController * searchTagsTableController;
    NSString *searchTerm;

    __weak NSMutableArray *entities;
}

typedef BOOL (^CheckEntitiesBlock)(BOOL end, NSMutableArray *entities);
- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(CheckEntitiesBlock)completion;
- (void)watchForEntities:(UITextView *)textField;
- (id)initWithTextView:(UITextView *)textView andEntities:(NSMutableArray *)inputEntities inController:(UIViewController *)controller andLinkID:(NSNumber *)linkerID reverseScroll:(BOOL)reverse tableOffset:(int)firstOffset secondTableOffset:(int)secondOffset characterLimit:(int)inputCharacterLimit;
- (void)resetTypingAttributes:(UITextView *)textField;
- (void)setLimitText;
- (void)hideEverything;

@end
