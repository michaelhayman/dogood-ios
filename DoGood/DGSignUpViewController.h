@class DGPhotoPickerViewController;

@interface DGSignUpViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIActionSheetDelegate> {
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UIImageView *avatarOverlay;
    __weak IBOutlet UITextField *name;

    DGUser *user;
    UIImage *imageToUpload;

    DGPhotoPickerViewController *photos;
}

@end
