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
    // [DGUser logOut];
    self.navigationController.navigationBarHidden = YES;
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:welcomeViewController animated:NO];
}


@end
