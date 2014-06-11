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

    [nameField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
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

#define nominee_name_field_tag 691
#define nominee_email_field_tag 692
#define nominee_phone_field_tag 693
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    switch (textField.tag) {
        case nominee_name_field_tag:
            [[self textFieldForTag:nominee_email_field_tag] becomeFirstResponder];
            break;
        case nominee_email_field_tag:
            [[self textFieldForTag:nominee_phone_field_tag] becomeFirstResponder];
            break;
        default:
            [textField resignFirstResponder];
            break;
    }
    return YES;
}

- (void)textFieldDidChange:(id)sender {
    NSString *teaserName;
    if ([nameField.text isEqualToString:@""]) {
        teaserName = @"them";
    } else {
        teaserName = nameField.text;
    }
    rewardTeaserText.text = [NSString stringWithFormat:@"Reward %@ by adding more information:", teaserName];
    rewardTeaserHeight.constant = [DGAppearance calculateHeightForString:rewardTeaserText.text WithFont:kGoodCaptionFont andWidth:nameField.frame.size.width + 30];
}


- (UITextField *)textFieldForTag:(int)tag {
    return (UITextField *)[self.view viewWithTag:tag];
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
