#import "DGUserSearchTwitterViewController.h"
#import "UserCell.h"
#import "DGTwitterManager.h"
#import "DGNominee.h"

@implementation DGUserSearchTwitterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Twitter";
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    tableView.delegate = self;
    tableView.dataSource = self;

    twitterManager = [[DGTwitterManager alloc] initWithAppName:APP_NAME];

    [self setupView];
    [self searchTwitterAndDisplayWarning:NO];
}

- (void)dealloc {
}

#pragma mark - Search Networks methods
- (void)showAuthorized {
    [super showAuthorized];
}

- (void)setupView {
    unauthorizedBackground.image = [UIImage imageNamed:@"TwitterWatermark"];
    [authorizeButton setTitle:@"Search Twitter friends" forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"SearchTwitterButton"] forState:UIControlStateNormal];
    contentDescription.text = @"Find Twitter friends on Do Good";
}

- (void)showUnauthorized {
    [super showUnauthorized];
    DebugLog(@"showing unauth");
    [authorizeButton setTitle:@"Search Twitter friends" forState:UIControlStateNormal];

    [authorizeButton addTarget:self action:@selector(searchTwitterWithWarning) forControlEvents:UIControlEventTouchUpInside];
}

- (void)showNoUsersFoundMessage {
    [self showUnauthorized];
    [authorizeButton setTitle:@"Try again" forState:UIControlStateNormal];
    [authorizeButton addTarget:self action:@selector(searchTwitterWithWarning) forControlEvents:UIControlEventTouchUpInside];
    noUsersLabel.hidden = NO;
    noUsersLabel.text = @"No Twitter friends found";
}

#pragma mark - Twitter
- (void)searchTwitterAndDisplayWarning:(BOOL)warning {
    DebugLog(@"check twitter access");
    [twitterManager findTwitterFriendsWithSuccess:^(BOOL success, NSArray *twitterUsers, ACAccount *account) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self findDoGoodUsersOnTwitter:twitterUsers];
            [[DGUser currentUser] saveSocialID:[twitterManager getTwitterIDFromAccount:account] withType:@"twitter"];
        });
    } failure:^(NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self showUnauthorized];

            if (warning) {
                [[[UIAlertView alloc] initWithTitle:@"Twitter Settings" message:@"Enable Twitter & Do Good under Settings > Twitter." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
            }
        });
    }];
}

- (void)searchTwitterWithWarning {
    [self searchTwitterAndDisplayWarning:YES];
}

- (void)findDoGoodUsersOnTwitter:(NSArray *)twitterUserIDs {
    if ([twitterUserIDs count] > 0) {
        NSString *path = [NSString stringWithFormat:@"/users/search_by_twitter_ids"];

        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        [dictionary setObject:NSNullIfNil(twitterUserIDs) forKey:@"twitter_ids"];

        [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:dictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            users = [[NSArray alloc] initWithArray:mappingResult.array];
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
        [self showNoUsersFoundMessage];
    }
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    // NSArray *users;
    DGUser *user = users[indexPath.row];
    cell.user = user;
    cell.disableSelection = self.disableSelection || NO;
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGUser *user = users[indexPath.row];
    DGNominee *nominee = [DGNominee new];
    [nominee configureForUser:user];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nominee forKey:@"nominee"];
    [[NSNotificationCenter defaultCenter] postNotificationName:ExternalNomineeWasChosen object:nil userInfo:dictionary];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
