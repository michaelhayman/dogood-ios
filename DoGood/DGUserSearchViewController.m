#import "DGUserSearchViewController.h"
#import "UserCell.h"
#import "DGNominee.h"

@implementation DGUserSearchViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Search for people"];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)dealloc {
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGUser *user = users[indexPath.row];
    cell.user = user;
    cell.disableSelection = YES;
    cell.navigationController = self.navigationController;
    [cell setValues];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGUser *user = users[indexPath.row];
    DGNominee *nominee = [DGNominee new];
    [nominee configureForUser:user];
    NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nominee forKey:@"nominee"];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGNomineeWasChosen object:nil userInfo:dictionary];
}

#pragma mark - Retrieval methods
- (void)getUsersByName:(NSString *)searchText {
    NSString *encodedSearch = [searchText stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];

    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/search?search=%@", encodedSearch] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
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

- (void)searchBarSearchButtonClicked:(UISearchBar *)theSearchBar {
    [theSearchBar resignFirstResponder];
}

@end
