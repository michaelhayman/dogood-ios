#import "DGUserProfileViewController.h"
#import "DGWelcomeViewController.h"

@interface DGUserProfileViewController ()

@end

@implementation DGUserProfileViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Profile";
    [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];

    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc] initWithTitle:@"Find Friends" style: UIBarButtonItemStylePlain target:self action:@selector(findFriends:)];
    // connectButton.tintColor = ADD_ITEM_BUTTON_COLOR;
    self.navigationItem.rightBarButtonItem = connectButton;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)findFriends:(id)sender {
}

@end
