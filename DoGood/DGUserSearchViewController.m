#import "DGUserSearchViewController.h"
#import "UserCell.h"

@implementation DGUserSearchViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Search for people"];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    DebugLog(@"frameage");
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
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

#pragma mark - Retrieval methods
- (void)getUsersByName:(NSString *)searchText {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/search?search=%@", searchText] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        users = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 1) {
        [self getUsersByName:searchText];
    } else {
        users = [[NSArray alloc] init];
        [tableView reloadData];
    }
}

@end
