@protocol DGPostGoodNomineeAddViewControllerDelegate;
@class DGNominee;
@interface DGPostGoodNomineeAddViewController : UIViewController {
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *phoneField;
    __weak IBOutlet UISwitch *inviteField;
    __weak IBOutlet UILabel *inviteText;
    __weak IBOutlet UIButton *nominateButton;
    DGNominee *nominee;
}

@property (nonatomic, weak) id <DGPostGoodNomineeAddViewControllerDelegate> delegate;

@end

@protocol DGPostGoodNomineeAddViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodNomineeAddViewController* )viewController didChooseNominee:(DGNominee *)nominee;

@end
