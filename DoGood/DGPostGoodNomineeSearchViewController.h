@protocol DGNomineeSearchViewControllerDelegate;
@class DGNominee;

@class Arrow;
@interface DGPostGoodNomineeSearchViewController : UIViewController {
    Arrow *arrow;
    NSInteger segmentIndex;

    __weak IBOutlet UIView *buttonRow;
    __weak IBOutlet UIButton *add;
    __weak IBOutlet UIButton *dogood;
    __weak IBOutlet UIButton *facebook;
    __weak IBOutlet UIButton *twitter;
    __weak IBOutlet UIButton *addressBook;

    UISegmentedControl *tabControl;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) id <DGNomineeSearchViewControllerDelegate> delegate;

@end
