#import "DGUserSearchFacebookViewController.h"
#import "UserCell.h"
#import "ThirdParties.h"

@implementation DGUserSearchFacebookViewController

- (void)viewDidLoad {
    self.title = @"Search Facebook";
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    tableView.delegate = self;
    tableView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(facebookConnected:) name:DGUserDidCheckIfFacebookIsConnected object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDoGoodUsersOnFacebook:) name:DGUserDidFindFriendsOnFacebook object:nil];

    [self setupView];
    [self showFacebook];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Search Networks methods
- (void)showAuthorized {
    [super showAuthorized];
}

- (void)setupView {
    [authorizeButton setTitle:@"Search for Facebook friends" forState:UIControlStateNormal];
    unauthorizedBackground.image = [UIImage imageNamed:@"FacebookWatermark"];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"FacebookButton"] forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"FacebookButtonTap"] forState:UIControlStateHighlighted];
}

- (void)showUnauthorized {
    [super showUnauthorized];
    [authorizeButton setTitle:@"Search for Facebook friends" forState:UIControlStateNormal];

    [authorizeButton addTarget:self action:@selector(showFacebook) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showNoUsersFoundMessage {
    [authorizeButton setTitle:@"Try again" forState:UIControlStateNormal];
    [authorizeButton addTarget:self action:@selector(tryHarder) forControlEvents:UIControlEventTouchUpInside];
    noUsersLabel.hidden = NO;
    noUsersLabel.text = @"No Facebook friends found";
}

#pragma mark - Facebook
- (void)facebookConnected:(NSNotification *)notification {
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    DebugLog(@"connected to fb? %@", connected);
    if ([connected boolValue]) {
        [ThirdParties performSelectorOnMainThread:@selector(getFacebookFriendsOnDoGood) withObject:nil waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(showUnauthorized) withObject:nil waitUntilDone:NO];
    }
}

- (void)showFacebook {
    contentDescription.text = @"Find Do Good friends on Facebook";
    // passive check first time
    [ThirdParties checkFacebookAccess];
}

- (void)tryHarder {
    [ThirdParties getFacebookFriendsOnDoGood];
}

- (void)findDoGoodUsersOnFacebook:(NSNotification *)notification {
    NSArray *facebookUserIDs = [[notification userInfo] valueForKey:@"facebook_ids"];

    if (facebookUserIDs.count > 0) {
        NSString *path = [NSString stringWithFormat:@"/users/search_by_facebook_ids"];
        [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:[notification userInfo] success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            users = [[NSArray alloc] initWithArray:mappingResult.array];
            DebugLog(@"do good users on facebook %@", users);
            if ([users count] > 0) {
                [self performSelectorOnMainThread:@selector(showAuthorized) withObject:nil waitUntilDone:NO];
                [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
                // [tableView reloadData];
            } else {
                // should be on main thread elsewhere too
                [self performSelectorOnMainThread:@selector(showNoUsersFoundMessage) withObject:nil waitUntilDone:NO];
            }
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            DebugLog(@"Operation failed with error: %@", error);
        }];
    } else {
        DebugLog(@"no data returned from fb");
        [self performSelectorOnMainThread:@selector(showNoUsersFoundMessage) withObject:nil waitUntilDone:NO];
        // 57	87	154
    }
}

- (void)failedToFindFriends:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUnauthorized];
        [TSMessage showNotificationInViewController:self
                                  withTitle:nil
                                withMessage:@"Couldn't connect to Facebook"
                                   withType:TSMessageNotificationTypeError];
    });

}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    // NSArray *users;
    DGUser *user = users[indexPath.row];
    cell.user = user;
    DebugLog(@"user %@", user);
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
