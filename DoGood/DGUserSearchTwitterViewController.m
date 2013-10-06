#import "DGUserSearchTwitterViewController.h"
#import "UserCell.h"
#import "ThirdParties.h"

@implementation DGUserSearchTwitterViewController

- (void)viewDidLoad {
    self.title = @"Search Twitter";
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    tableView.delegate = self;
    tableView.dataSource = self;

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(twitterConnected:) name:DGUserDidCheckIfTwitterIsConnected object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(findDoGoodUsersOnTwitter:) name:DGUserDidFindFriendsOnTwitter object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(failedToFindFriends:) name:DGUserDidFailFindFriendsOnTwitter object:nil];

    [self setupView];
    [self showTwitter];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Search Networks methods
- (void)showAuthorized {
    [super showAuthorized];
}

- (void)setupView {
    unauthorizedBackground.image = [UIImage imageNamed:@"TwitterWatermark"];
    [authorizeButton setTitle:@"Search Twitter friends" forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"TwitterButton"] forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"TwitterButtonTap"] forState:UIControlStateHighlighted];
}

- (void)showUnauthorized {
    [super showUnauthorized];
    [authorizeButton setTitle:@"Search Twitter friends" forState:UIControlStateNormal];

    [authorizeButton addTarget:self action:@selector(checkTwitterAccessWithPrompt) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showNoUsersFoundMessage {
    [self showUnauthorized];
    [authorizeButton setTitle:@"Try again" forState:UIControlStateNormal];
    [authorizeButton addTarget:self action:@selector(showTwitter) forControlEvents:UIControlEventTouchUpInside];
    noUsersLabel.hidden = NO;
    noUsersLabel.text = @"No Twitter friends found";
}

#pragma mark - Twitter
- (void)showTwitter {
    contentDescription.text = @"Find Twitter friends on Do Good";
    [ThirdParties checkTwitterAccess:NO];
}

- (void)checkTwitterAccessWithPrompt {
    [ThirdParties checkTwitterAccess:YES];
}

- (void)twitterConnected:(NSNotification *)notification {
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    if ([connected boolValue]) {
        // [ThirdParties getTwitterFriendsOnDoGood];
        [ThirdParties performSelectorOnMainThread:@selector(getTwitterFriendsOnDoGood) withObject:nil waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(showUnauthorized) withObject:nil waitUntilDone:NO];
    }
}

- (void)findDoGoodUsersOnTwitter:(NSNotification *)notification {
    NSArray *twitterUserIDs= [[notification userInfo] valueForKey:@"ids"];
    NSString *path = [NSString stringWithFormat:@"/users/search_by_twitter_ids"];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:NSNullIfNil(twitterUserIDs) forKey:@"twitter_ids"];

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:dictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        users = [[NSArray alloc] initWithArray:mappingResult.array];
        DebugLog(@"do good users on twitter %@", users);
        if ([users count] > 0) {
            [self performSelectorOnMainThread:@selector(showAuthorized) withObject:nil waitUntilDone:NO];
            [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(showNoUsersFoundMessage) withObject:nil waitUntilDone:NO];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [self performSelectorOnMainThread:@selector(showUnauthorized) withObject:nil waitUntilDone:NO];
    }];
}

- (void)failedToFindFriends:(NSNotification *)notification {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self showUnauthorized];
        [TSMessage showNotificationInViewController:self
                                  title:nil
                                           subtitle:@"Couldn't connect to Twitter"
                                   type:TSMessageNotificationTypeError];
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
