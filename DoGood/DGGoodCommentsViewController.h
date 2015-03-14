#import "DGComment.h"
@class DGGood;
@class DGComment;
@class GoodCell;
@class DGEntityHandler;
@class SAMLoadingView;

@interface DGGoodCommentsViewController : DGViewController <UITextViewDelegate, UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentFieldBottom;
@property (nonatomic, weak) UIView *commentInputView;
@property (nonatomic, weak) IBOutlet UITextView *commentInputField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentInputFieldHeight;
@property (nonatomic, weak) NSLayoutConstraint *commentBoxHeight;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *comments;
@property (nonatomic) NSInteger page;

@property (nonatomic, weak) IBOutlet UIButton *sendButton;

// entities
@property (nonatomic) int characterLimit;
@property (nonatomic) CGFloat totalKeyboardHeight;
@property (nonatomic, strong) NSMutableArray *entities;
@property (nonatomic, strong) DGEntityHandler *entityHandler;
@property (nonatomic, strong) SAMLoadingView *loadingView;
@property (nonatomic, copy) NSString *loadingStatus;

@property (nonatomic) BOOL makeComment;
@property (nonatomic) DGGood *good;
@property (nonatomic, weak) GoodCell *goodCell;

@end
