#import "DGPostGoodNomineeAddViewController.h"
#import "DGPostGoodNomineeSearchViewController.h"
#import "DGNominee.h"
#import <ReactiveCocoa/ReactiveCocoa.h>
#import <ProgressHUD/ProgressHUD.h>

@implementation DGPostGoodNomineeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    nominee = [DGNominee new];
    [[nominateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        DebugLog(@"button tapped");
        [self checkInputSilently:NO];
    }];

    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    photos.delegate = self;
    UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoSheet)];
    [avatarImage setUserInteractionEnabled:YES];
    [avatarImage addGestureRecognizer:imageGesture];
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

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)fillInFieldsFromNominee:(DGNominee *)theNominee {
    nominee = theNominee;
    nameField.text = nominee.full_name;
    avatarImage.image = nominee.avatarImage;
    phoneField.text = nominee.phone;
    emailField.text = nominee.email;
}

- (void)fillInNomineeFromFields {
    nominee.full_name = nameField.text;
    nominee.avatarImage = avatarImage.image;
    nominee.phone = phoneField.text;
    nominee.email = emailField.text;
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
