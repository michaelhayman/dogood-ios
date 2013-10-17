#import "DGUserSearchFacebookViewController.h"
#import "UserCell.h"
#import "DGFacebookManager.h"

@interface DGUserSearchFacebookViewController () <UIActionSheetDelegate>
@end

@implementation DGUserSearchFacebookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Facebook";
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    tableView.delegate = self;
    tableView.dataSource = self;

    facebookManager = [[DGFacebookManager alloc] initWithAppName:APP_NAME];

    [self setupView];
    [self searchFacebookAndDisplayWarning:NO];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)setupView {
    [authorizeButton setTitle:@"Search for Facebook friends" forState:UIControlStateNormal];
    unauthorizedBackground.image = [UIImage imageNamed:@"FacebookWatermark"];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"FacebookButton"] forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"FacebookButtonTap"] forState:UIControlStateHighlighted];
    [authorizeButton addTarget:self action:@selector(searchFacebookWithWarning) forControlEvents:UIControlEventTouchUpInside];
    contentDescription.text = @"Find Facebook friends on Do Good";
}

- (void)searchFacebookAndDisplayWarning:(BOOL)warning {
    [facebookManager findFacebookFriendsWithSuccess:^(BOOL success, NSArray *facebookUsers, ACAccount *account) {
        dispatch_async(dispatch_get_main_queue(), ^{
           [self findDoGoodUsersOnFacebook:facebookUsers];

           [facebookManager findFacebookIDForAccount:account withSuccess:^(BOOL success, NSString *facebookID) {
               [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
            } failure:^(NSError *findError) {
                 DebugLog(@"didn't find id");
            }];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUnauthorized];

            if (warning) {
                [[[UIAlertView alloc] initWithTitle:@"Facebook Settings" message:@"Enable Facebook & Do Good under Settings > Facebook." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    }];
}

- (void)searchFacebookWithWarning {
    [self searchFacebookAndDisplayWarning:YES];
}

#pragma mark - Search Networks methods
- (void)showAuthorized {
    [super showAuthorized];
}

- (void)showUnauthorized {
    [super showUnauthorized];
    [authorizeButton setTitle:@"Search for Facebook friends" forState:UIControlStateNormal];
    [authorizeButton addTarget:self action:@selector(searchFacebookWithWarning) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showNoUsersFoundMessage {
    [authorizeButton setTitle:@"Try again" forState:UIControlStateNormal];
    [authorizeButton addTarget:self action:@selector(searchFacebookWithWarning) forControlEvents:UIControlEventTouchUpInside];
    noUsersLabel.hidden = NO;
    noUsersLabel.text = @"No Facebook friends found";
}

- (void)findDoGoodUsersOnFacebook:(NSArray *)facebookUserIDs {
    if (facebookUserIDs.count > 0) {
        NSString *path = [NSString stringWithFormat:@"/users/search_by_facebook_ids"];

        NSDictionary *params = [NSDictionary dictionaryWithObject:NSNullIfNil(facebookUserIDs) forKey:@"facebook_ids"];

        [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            users = [[NSArray alloc] initWithArray:mappingResult.array];
            // DebugLog(@"do good users on facebook %@", users);
            [tableView reloadData];
            if ([users count] > 0) {
                [self showAuthorized];
            } else {
                [self showNoUsersFoundMessage];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"Operation failed with error: %@", error);
            [self showUnauthorized];
        }];
    } else {
        // DebugLog(@"no data returned from fb");
        [self showNoUsersFoundMessage];
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGUser *user = users[indexPath.row];
    cell.user = user;
    // DebugLog(@"user %@", user);
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [users count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
