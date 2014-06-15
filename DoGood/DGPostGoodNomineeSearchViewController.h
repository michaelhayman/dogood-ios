@protocol DGNomineeSearchViewControllerDelegate;
@protocol DGPostGoodNomineeViewControllerDelegate;
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
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) id <DGNomineeSearchViewControllerDelegate> delegate;
@property (nonatomic, weak) id <DGPostGoodNomineeViewControllerDelegate> postGoodDelegate;

- (void)chooseAdd;

@end

@protocol DGPostGoodNomineeViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodNomineeSearchViewController* )viewController didChooseNominee:(DGNominee *)nominee;

@end