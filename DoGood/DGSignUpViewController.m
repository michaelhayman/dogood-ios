#import "DGSignUpViewController.h"
#import "DGSignUpDetailsViewController.h"
#import "DGPhotoPickerViewController.h"
#import <MBProgressHUD.h>

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
    // [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
    [name becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatar:) name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAvatar) name:DGUserDidRemovePhotoNotification object:nil];
}

- (void)viewWillDisappear:(BOOL)animated {
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidRemovePhotoNotification object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Verify account creation
- (IBAction)verifyNext:(id)sender {
    DGUser *submitUser = [DGUser new];
    submitUser.full_name = name.text;

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.navigationController.view animated:YES];
    hud.labelText = @"Checking name...";
    [[RKObjectManager sharedManager] postObject:submitUser path:@"/users/validate_name" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [name resignFirstResponder];
        if (user.image == nil) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No photo?" message:@"C'mon, upload an image!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
            alert.cancelButtonIndex = 1;
            alert.tag = 59;
            [alert show];
        } else {
            [self showNextStep];
        }
        [hud hide:YES];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self.navigationController title:@"Oops" subtitle:[error localizedDescription] type:TSMessageNotificationTypeError];
        [hud hide:YES];
    }];
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
    if (textField == name) {
        [self verifyNext:textField];
    }
    return YES;
}

@end
