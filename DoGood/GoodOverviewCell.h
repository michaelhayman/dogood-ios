@class DGEntityHandler;

@interface GoodOverviewCell : UITableViewCell <UITextViewDelegate> {
    // entities
    int characterLimit;
    CGFloat totalKeyboardHeight;
}

@property (weak, nonatomic) IBOutlet UITextView *descriptionText;
@property (weak, nonatomic) IBOutlet UITextView *placeholder;

@property (strong, nonatomic) DGEntityHandler *entityHandler;

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (nonatomic) NSMutableArray *entities;
@property (weak, nonatomic) UIViewController *parent;

- (UIImage *)defaultImage;
- (void)restoreDefaultImage;
- (void)initEntityHandler;
- (void)setDoneMode:(BOOL)done;

@end
