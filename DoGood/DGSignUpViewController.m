#import "DGSignUpViewController.h"
#import "DGSignUpDetailsViewController.h"

@interface DGSignUpViewController ()

@end

@implementation DGSignUpViewController

#pragma mark - View management
- (void)viewDidLoad {
    [super viewDidLoad];
    user = [DGUser new];

    UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoSheet)];
    [avatar setUserInteractionEnabled:YES];
    [avatar addGestureRecognizer:imageGesture];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.backgroundColor = COLOUR_OFF_WHITE;

    // [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
}

#pragma mark - Verify account creation
- (IBAction)verifyNext:(id)sender {
    if ([name.text isEqualToString:@""]) {
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:nil
                                           subtitle:@"Name required"
                                   type:TSMessageNotificationTypeError];
    } else {
        [name resignFirstResponder];
        if (user.image == nil) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No photo?"
                                                            message:@"C'mon, upload an image!"
                                                           delegate:self
                                                  cancelButtonTitle:nil
                                                  otherButtonTitles:@"Yes", @"No", nil];
            alert.cancelButtonIndex = 1;
            alert.tag = 59;
            [alert show];
        } else {
            [self showNextStep];
        }
    }
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if(alertView.tag == 59) {
        if(buttonIndex == 0) {
            [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
            [self openPhotoSheet];
        } else {
            [self showNextStep];
        }
    }
}

- (void)showNextStep {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGSignUpDetailsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"SignUpDetails"];
    user.image = avatar.image;
    user.full_name = name.text;
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - UIActionSheetDelegate methods
- (void)openPhotoSheet {
    avatar.highlighted = YES;
    NSString *destructiveButtonTitle;
    if (user.image) {
        destructiveButtonTitle = @"Remove photo";
    } else {
        destructiveButtonTitle = nil;
    }

    photoSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:destructiveButtonTitle
                                       otherButtonTitles:@"Add from camera", @"Add from camera roll", nil];
    [photoSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [photoSheet showInView:self.view];
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == photoSheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == photoSheet.destructiveButtonIndex) {
                DebugLog(@"remove");
                avatar.image = nil;
                user.image = nil;
                avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex) {
                [self showCamera];
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex + 1) {
                [self showCameraRoll];
            }
        }
    } else {
        DebugLog(@"button index %d, %d", buttonIndex, actionSheet.cancelButtonIndex);
        // [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
    }
}

#pragma mark - Camera helpers
- (void)showCameraRoll {
    DebugLog(@"show camera roll");
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    pickerC.allowsEditing = YES;
    [self presentViewController:pickerC animated:YES completion:nil];
}

- (void)showCamera {
    DebugLog(@"show camera");
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    imageToUpload = [info objectForKey:UIImagePickerControllerEditedImage];
    // imageToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];
    user.image = imageToUpload;
    avatar.image = user.image;
    avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
    [avatar bringSubviewToFront:avatarOverlay];
}

#pragma mark - UITextFieldDelegate
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    DebugLog(@"what");
    if (textField == name) {
        [self verifyNext:textField];
    }
    return YES;
}

@end
