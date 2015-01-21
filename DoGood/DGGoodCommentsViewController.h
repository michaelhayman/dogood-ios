#import "DGComment.h"
@class DGGood;
@class DGComment;
@class GoodCell;
@class DGEntityHandler;
@class SAMLoadingView;

@interface DGGoodCommentsViewController : DGViewController <UITextViewDelegate> {
    __weak IBOutlet NSLayoutConstraint *commentFieldBottom;
    __weak IBOutlet UIView *commentInputView;
    __weak IBOutlet UITextView *commentInputField;
    __weak IBOutlet NSLayoutConstraint *commentInputFieldHeight;
    __weak IBOutlet NSLayoutConstraint *commentBoxHeight;

    __weak IBOutlet UITableView *tableView;
    NSMutableArray *comments;
    NSInteger page;

    __weak IBOutlet NSLayoutConstraint *tableViewBottom;
    __weak IBOutlet UIButton *sendButton;

    // entities
    int characterLimit;
    CGFloat totalKeyboardHeight;
    NSMutableArray *entities;
    DGEntityHandler *entityHandler;
    SAMLoadingView *loadingView;
    NSString *loadingStatus;
}

@property BOOL makeComment;
@property DGGood *good;
@property (nonatomic, weak) GoodCell *goodCell;

@end
