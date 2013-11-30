@protocol DGPostGoodNomineeViewControllerDelegate;
@class DGNominee;

#import "DGPostGoodNomineeAddViewController.h"

@interface DGPostGoodNomineeViewController : UIViewController <DGPostGoodNomineeAddViewControllerDelegate> {
    UISegmentedControl *tabControl;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (nonatomic, weak) IBOutlet UIView *contentView;
@property (nonatomic, weak) id <DGPostGoodNomineeViewControllerDelegate> delegate;

@end

@protocol DGPostGoodNomineeViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodNomineeViewController* )viewController didChooseNominee:(DGNominee *)nominee;

@end