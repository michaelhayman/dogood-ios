#import "DGSignUpViewController.h"
#import "DGSignUpDetailsViewController.h"
#import "DGPhotoPickerViewController.h"
#import <ProgressHUD/ProgressHUD.h>

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
    photos.delegate = self;
    photos.initiatorView = avatar;
    // [[UITextField appearance] setBorderStyle:UITextBorderStyleNone];
    [name becomeFirstResponder];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Sign Up"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

#pragma mark - Verify account creation
- (IBAction)verifyNext:(id)sender {
    DGUser *submitUser = [DGUser new];
    submitUser.full_name = name.text;

    [ProgressHUD show:@"Checking name..."];
    [name resignFirstResponder];
    [[RKObjectManager sharedManager] postObject:submitUser path:@"/users/validate_name" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [name resignFirstResponder];
        if (user.avatar == nil) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"No photo?" message:@"C'mon, upload an image!" delegate:self cancelButtonTitle:nil otherButtonTitles:@"Yes", @"No", nil];
            alert.cancelButtonIndex = 1;
            alert.tag = 59;
            [alert show];
        } else {
            [self showNextStep];
        }
        [ProgressHUD dismiss];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [DGMessage showErrorInViewController:self.navigationController title:@"Error" subtitle:[error localizedDescription]];
        [ProgressHUD dismiss];
        [name becomeFirstResponder];
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
    user.avatar = avatar.image;
    user.full_name = name.text;
    controller.user = user;
    [self.navigationController pushViewController:controller animated:YES];
}

#pragma mark - Avatar & DGPhotoPickerViewController
- (void)openPhotoPicker {
    [photos openPhotoSheet:avatar.image];
}

- (void)childViewController:(DGPhotoPickerViewController *)viewController didChoosePhoto:(NSDictionary *)dictionary {
    imageToUpload = [dictionary objectForKey:UIImagePickerControllerEditedImage];
    user.avatar = imageToUpload;
    avatar.image = user.avatar;
    avatarOverlay.image = [UIImage imageNamed:@"EditProfilePhotoFrame"];
    [avatar bringSubviewToFront:avatarOverlay];
}

- (void)removePhoto {
    avatar.image = nil;
    user.avatar = nil;
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
