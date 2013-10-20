#define TEXTVIEW_TEXT @"Tell the world about the good you did"
@class DGEntityHandler;

@interface GoodOverviewCell : UITableViewCell <UITextViewDelegate> {
    // entities
    int characterLimit;
    CGFloat totalKeyboardHeight;
    DGEntityHandler *entityHandler;
}

@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) NSMutableArray *entities;
@property (weak, nonatomic) UIViewController *parent;

- (UIImage *)defaultImage;
- (void)initEntityHandler;

@end
