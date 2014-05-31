#import "DGPostGoodNomineeAddViewController.h"
#import "DGPostGoodNomineeSearchViewController.h"
#import "DGNominee.h"
#import <ProgressHUD/ProgressHUD.h>
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@implementation DGPostGoodNomineeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    nominee = [DGNominee new];

    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    photos.delegate = self;
    UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoSheet)];
    [avatarImage setUserInteractionEnabled:YES];
    [avatarImage addGestureRecognizer:imageGesture];

    [DGAppearance styleActionButton:nominateButton];
    [nominateButton addTarget:self action:@selector(nominateButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    [inviteField addTarget:self action:@selector(checkInvite) forControlEvents:UIControlEventValueChanged];
}

- (void)checkInvite {
    if ([inviteField isOn]) {
        [self fillInNomineeFromFields];
        if (![nominee isContactable]) {
            [UIAlertView showWithTitle:@"Enter Contact Details" message:@"Enter an email address or phone number to invite a nominee." cancelButtonTitle:@"OK" otherButtonTitles:@[] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
                inviteField.on = NO;
            }];
        }
    }
}

- (IBAction)nominateButtonPressed:(id)sender {
    [self checkInputSilently:NO];
}

- (void)checkInputSilently:(BOOL)silent {
    BOOL errors = YES;
    NSString *message;
    if ([nameField.text length] == 0) {
        errors = YES;
        message = @"Insufficient name input.";
    } else {
        errors = NO;
    }

    if (!errors) {
        [self fillInNomineeFromFields];
        [self nominate:nil];
    } else {
        if (!silent) {
            [ProgressHUD showError:message];
        } else {
            DebugLog(@"%@", message);
        }
    }
}

- (void)openPhotoSheet {
    [photos openPhotoSheet:nominee.avatarImage];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fillInFieldsFromNominee:(DGNominee *)theNominee {
    nominee = theNominee;
    nameField.text = nominee.full_name;
    avatarImage.image = nominee.avatarImage;
    phoneField.text = nominee.phone;
    emailField.text = nominee.email;
    inviteField.on = [nominee.invite boolValue];
}

- (void)fillInNomineeFromFields {
    nominee.full_name = nameField.text;
    nominee.avatarImage = avatarImage.image;
    nominee.phone = phoneField.text;
    nominee.email = emailField.text;
    nominee.invite = [NSNumber numberWithBool:inviteField.on];
}

- (IBAction)nominate:(id)sender {
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nominee forKey:@"nominee"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGNomineeWasChosen object:nil userInfo:dictionary];
}

- (void)childViewController:(DGPhotoPickerViewController* )viewController didChoosePhoto:(NSDictionary *)dictionary {
    UIImage *imageToUpload = [dictionary objectForKey:UIImagePickerControllerEditedImage];
    nominee.avatarImage = imageToUpload;
    avatarImage.image = nominee.avatarImage;
}

- (void)removePhoto {
    avatarImage.image = nil;
}

@end
