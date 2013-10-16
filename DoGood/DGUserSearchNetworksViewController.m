#import "DGUserSearchNetworksViewController.h"
#import "constants.h"

@interface DGUserSearchNetworksViewController ()
@end

@implementation DGUserSearchNetworksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    contentDescription.backgroundColor = COLOUR_SEARCH_NETWORKS_BACKGROUND;
    contentDescription.textColor = [UIColor blackColor];
}

- (void)showAuthorized {
    authorizedView.hidden = NO;
    unauthorizedView.hidden = YES;
}

- (void)showUnauthorized {
    authorizedView.hidden = YES;
    unauthorizedView.hidden = NO;
    noUsersLabel.hidden = YES;
}

@end
