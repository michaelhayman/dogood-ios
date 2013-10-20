@class DGEntityHandler;

@interface GoodOverviewCell : UITableViewCell <UITextViewDelegate> {
    // entities
    int characterLimit;
    CGFloat totalKeyboardHeight;
    DGEntityHandler *entityHandler;
}

@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UILabel *placeholder;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) NSMutableArray *entities;
@property (weak, nonatomic) UIViewController *parent;

- (UIImage *)defaultImage;
- (void)initEntityHandler;

@end
