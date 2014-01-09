@protocol DGPostGoodNomineeAddViewControllerDelegate;
@class DGNominee;

#import "DGPhotoPickerViewController.h"

@interface DGPostGoodNomineeAddViewController : UIViewController <DGPhotoPickerViewControllerDelegate> {
    __weak IBOutlet UITextField *nameField;
    __weak IBOutlet UITextField *emailField;
    __weak IBOutlet UITextField *phoneField;
    __weak IBOutlet UISwitch *inviteField;
    __weak IBOutlet UILabel *inviteText;
    __weak IBOutlet UIButton *nominateButton;
    DGNominee *nominee;
    DGPhotoPickerViewController *photos;
    __weak IBOutlet UIImageView *avatarImage;
}

@property (nonatomic, weak) id <DGPostGoodNomineeAddViewControllerDelegate> delegate;

- (void)checkInputSilently:(BOOL)silent;
- (void)fillInFieldsFromNominee:(DGNominee *)theNominee;
- (IBAction)nominate:(id)sender;

@end

@protocol DGPostGoodNomineeAddViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodNomineeAddViewController* )viewController didChooseNominee:(DGNominee *)nominee;

@end
