#import "DGUserSearchNetworksViewController.h"

@interface DGUserSearchNetworksViewController ()
@end

@implementation DGUserSearchNetworksViewController

- (void)viewDidLoad {
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
