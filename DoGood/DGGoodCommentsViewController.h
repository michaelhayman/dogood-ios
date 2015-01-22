#import "DGComment.h"
@class DGGood;
@class DGComment;
@class GoodCell;
@class DGEntityHandler;
@class SAMLoadingView;

@interface DGGoodCommentsViewController : DGViewController <UITextViewDelegate>

@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentFieldBottom;
@property (nonatomic, weak) UIView *commentInputView;
@property (nonatomic, weak) IBOutlet UITextView *commentInputField;
@property (nonatomic, weak) IBOutlet NSLayoutConstraint *commentInputFieldHeight;
@property (nonatomic, weak) NSLayoutConstraint *commentBoxHeight;

@property (nonatomic, weak) IBOutlet UITableView *tableView;
@property (nonatomic, strong) NSMutableArray *comments;
@property NSInteger page;

@property (nonatomic, weak) IBOutlet UIButton *sendButton;

// entities
@property int characterLimit;
@property CGFloat totalKeyboardHeight;
@property (nonatomic, strong) NSMutableArray *entities;
@property (nonatomic, strong) DGEntityHandler *entityHandler;
@property (nonatomic, strong) SAMLoadingView *loadingView;
@property (nonatomic, copy) NSString *loadingStatus;

@property BOOL makeComment;
@property DGGood *good;
@property (nonatomic, weak) GoodCell *goodCell;

@end
