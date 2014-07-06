@class DGUserProfileViewController;

@interface DGExploreViewController : DGViewController <UITextFieldDelegate> {
    __weak IBOutlet UIView *searchFieldWrapper;
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UIButton *searchButton;
    __weak IBOutlet NSLayoutConstraint *searchFieldOffsetWidth;
    __weak IBOutlet NSLayoutConstraint *cancelButtonOffsetWidth;

    DGUserProfileViewController *userProfileController;

    NSInteger segmentIndex;
}

@property (nonatomic, strong) UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end
