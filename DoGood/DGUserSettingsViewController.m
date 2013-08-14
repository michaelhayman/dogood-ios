#import "DGUserSettingsViewController.h"

@interface DGUserSettingsViewController ()

@end

@implementation DGUserSettingsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Settings";

    /*
    UIBarButtonItem *connectButton = [[UIBarButtonItem alloc]initWithTitle:@"Sign Out" style: UIBarButtonItemStylePlain target:self action:@selector(signOut:)];
    self.navigationItem.rightBarButtonItem = connectButton;
    */
}

#pragma mark - Actions
- (void)signOut {
    [[DGUser currentUser] signOutWithMessage:YES];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"SignOut" object:nil];
}

#pragma mark - Update Account
- (void)updateFirstName:(NSString *)firstName andLastName:(NSString *)lastName andContactable:(NSNumber *)contactable {
    DGUser *user;
    user.name = firstName;
    user.phone = lastName;
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

#pragma mark - UITableView delegate methods
/*
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    // return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}
*/

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == signOut) {
        [self signOut];
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES]; 
}

@end
