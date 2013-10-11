#import "DGSignUpViewController.h"
#import "DGSignUpDetailsViewController.h"
#import "DGPhotoPickerViewController.h"

@interface DGSignUpViewController ()

@end

@implementation DGSignUpViewController

#pragma mark - View management
- (void)viewDidLoad {
    [super viewDidLoad];
    user = [DGUser new];

    UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoPicker)];
    [avatar setUserInteractionEnabled:YES];
    [avatar addGestureRecognizer:imageGesture];
    avatar.contentMode = UIViewContentModeScaleAspectFit;
    avatar.backgroundColor = COLOUR_OFF_WHITE;

    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatar:) name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAvatar) name:DGUserDidRemovePhotoNotification object:nil];
    // [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidRemovePhotoNotification object:nil];
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
            [self openPhotoPicker];
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

#pragma mark - Avatar & DGPhotoPickerViewController
- (void)openPhotoPicker {
    [photos openPhotoSheet:avatar.image];
}

- (void)uploadAvatar:(NSNotification *)notification  {
    imageToUpload = [[notification userInfo] objectForKey:UIImagePickerControllerEditedImage];
    user.image = imageToUpload;
    avatar.image = user.image;
    avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
    [avatar bringSubviewToFront:avatarOverlay];
}

- (void)deleteAvatar {
    avatar.image = nil;
    user.image = nil;
    avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
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
