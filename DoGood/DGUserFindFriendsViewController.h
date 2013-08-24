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

@property (weak, nonatomic) IBOutlet UISegmentedControl *typeSegmentedControl;
@property (nonatomic, retain)    UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
- (IBAction)segmentChanged:(UISegmentedControl *)sender;

@end
