@interface DGSignUpViewController : UIViewController <UITextFieldDelegate, UIAlertViewDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UINavigationControllerDelegate> {
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UIImageView *avatarOverlay;
    __weak IBOutlet UITextField *name;
    UIActionSheet * photoSheet;
    DGUser *user;
    UIImage *imageToUpload;
}

- (void)showCamera;
- (void)showCameraRoll;

@end
