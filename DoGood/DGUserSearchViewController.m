#import "DGUserSearchViewController.h"
#import "UserCell.h"
#import "NominateExplanationCell.h"
#import "DGNominee.h"

@implementation DGUserSearchViewController

#pragma mark - View lifecycle

#define kNominateExplanationCell @"NominateExplanationCell"
#define kUserCell @"UserCell"

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Search for people"];

    UINib *nib = [UINib nibWithNibName:kUserCell bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:kUserCell];

    UINib *nominateNib = [UINib nibWithNibName:kNominateExplanationCell bundle:nil];
    [tableView registerNib:nominateNib forCellReuseIdentifier:kNominateExplanationCell];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"User Search"];
}

- (void)dealloc {
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self searchBarEmpty] && [self showNominateExplanation]) {
        static NSString * reuseIdentifier = kNominateExplanationCell;
        NominateExplanationCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.parent = self.parent;
        return cell;
    } else {
        static NSString * reuseIdentifier = kUserCell;
        UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGUser *user = users[indexPath.row];
        cell.user = user;
        cell.disableSelection = YES;
        cell.navigationController = self.navigationController;
        [cell setValues];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self searchBarEmpty] && [self showNominateExplanation]) {
        return 300;
    } else {
        return 60;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if ([self searchBarEmpty] && [self showNominateExplanation]) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 1;
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return [users count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (BOOL)searchBarEmpty {
    return [searchBar.text isEqualToString:@""];
}

- (BOOL)showNominateExplanation {
    return [self.searchType isEqualToString:@"nominate"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (![self searchBarEmpty]) {
        DGUser *user = users[indexPath.row];
        DGNominee *nominee = [DGNominee new];
        [nominee configureForUser:user];
        NSDictionary *dictionary = [NSDictionary dictionaryWithObject:nominee forKey:@"nominee"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGNomineeWasChosen object:nil userInfo:dictionary];
    } else {
        [self.view endEditing:YES];
    }
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
