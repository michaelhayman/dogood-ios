#import "DGUserSearchOtherViewController.h"
#import "DGUserInvitesViewController.h"
#import "DGUserFindFriendsViewController.h"


@implementation DGUserSearchOtherViewController

- (void)viewDidLoad {
    self.title = @"Search";
    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = self;
    [DGAppearance styleActionButton:searchButton];
    [DGAppearance styleActionButton:inviteTextButton];
    [DGAppearance styleActionButton:inviteEmailButton];
}

- (void)dealloc {
}

#pragma mark - Internal search
- (IBAction)searchForPeople:(id)sender {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserFindFriendsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserSearch"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)inviteViaText:(id)sender {
    [invites setInviteText];
    [invites sendViaText:nil];
}

- (IBAction)inviteViaEmail:(id)sender {
    [invites setInviteText];
    [invites sendViaEmail:nil];
}
@end
