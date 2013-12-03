#import "DGPostGoodNomineeAddViewController.h"
#import "DGNominee.h"
#import <ReactiveCocoa/ReactiveCocoa.h>

@implementation DGPostGoodNomineeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    nominee = [DGNominee new];
    [[nominateButton rac_signalForControlEvents:UIControlEventTouchUpInside] subscribeNext:^(id x) {
        NSLog(@"button tapped");
        BOOL errors = YES;
        NSString *message;
        if ([nameField.text length] == 0) {
            errors = YES;
            message = @"Insufficient name input.";
        } else {
            errors = NO;
        }

        if (!errors) {
            nominee.full_name = nameField.text;
            nominee.avatarImage = avatarImage.image;
            [self nominate:nil];
        } else {
            DebugLog(@"%@", message);
        }
    }];

    /*
    RACSignal *nameSignal = [nameField.rac_textSignal map:^id(NSString *value) {
        return value;
    }];

    [nameSignal map:^id(NSString *value) {
        nominee.full_name = value;
        return nominee;
    }];
    */
    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    photos.delegate = self;
    UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoSheet)];
    [avatarImage setUserInteractionEnabled:YES];
    [avatarImage addGestureRecognizer:imageGesture];
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

- (void)fillInNominee:(DGNominee *)theNominee {
    nominee = theNominee;
    nameField.text = nominee.full_name;
    emailField.text = nominee.email;
    avatarImage.image = nominee.avatarImage;
}

- (IBAction)nominate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(childViewController:didChooseNominee:)]) {
        [self.delegate childViewController:self didChooseNominee:nominee];
    }
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
