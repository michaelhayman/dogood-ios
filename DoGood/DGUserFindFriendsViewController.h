@class Arrow;
@interface DGUserFindFriendsViewController : UIViewController {
    Arrow *arrow;
    NSInteger segmentIndex;

    __weak IBOutlet UIView *buttonRow;
    __weak IBOutlet UIButton *other;
    __weak IBOutlet UIButton *facebook;
    __weak IBOutlet UIButton *twitter;
    __weak IBOutlet UIButton *addressBook;
}

@property (nonatomic, weak) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *contentView;

@end
