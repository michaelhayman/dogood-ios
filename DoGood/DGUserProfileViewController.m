#import "DGUserProfileViewController.h"
#import "DGWelcomeViewController.h"

@interface DGUserProfileViewController ()

@end

@implementation DGUserProfileViewController

#pragma mark - View lifecycle
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Hi Basimah";
    [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];

    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style: UIBarButtonItemStylePlain target:self action:@selector(signOut:)];
    // connectButton.tintColor = ADD_ITEM_BUTTON_COLOR;
    self.navigationItem.rightBarButtonItem = connectButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)signOut:(id)sender {
    [[DGUser currentUser] signOutWithMessage:YES];
    self.navigationController.navigationBarHidden = YES;
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    self.navigationController.navigationBarHidden = YES;
    // [self.navigationController pushViewController:welcomeViewController animated:NO];
}

#pragma mark - Update Account
- (void)updateFirstName:(NSString *)firstName andLastName:(NSString *)lastName andContactable:(NSNumber *)contactable {
    DGUser *user;
    user.first_name = firstName;
    user.last_name = lastName;
    user.contactable = contactable;
    [[RKObjectManager sharedManager] putObject:user path:user_registration_path parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [TSMessage showNotificationInViewController:self
                              withTitle:NSLocalizedString(@"Saved!", nil)
                            withMessage:NSLocalizedString(@"Your profile was updated.", nil)
                               withType:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateAccountNotification object:self];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [TSMessage showNotificationInViewController:self
                              withTitle:NSLocalizedString(@"Oops", nil)
                            withMessage:NSLocalizedString(@"Couldn't update your profile.", nil)
                               withType:TSMessageNotificationTypeSuccess];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailUpdateAccountNotification object:self];
    }];
}

@end
