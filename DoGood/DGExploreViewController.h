#import "RootViewController.h"

@interface DGExploreViewController : RootViewController <UITextFieldDelegate> {
    __weak IBOutlet UIView *searchFieldWrapper;
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UIButton *searchButton;
    __weak IBOutlet NSLayoutConstraint *searchFieldWidth;

    NSInteger segmentIndex;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end
