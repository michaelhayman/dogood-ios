#import "DGExploreSearchPeopleTableViewController.h"
#import "UserCell.h"
#import "NoResultsCell.h"
#import "constants.h"

@implementation DGExploreSearchPeopleTableViewController

- (id)init {
    self = [super init];
    if (self) {
        showNoResultsMessage = NO;
        users = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emptyTable) name:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)emptyTable {
    [users removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"UserCell";
        UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGUser *user = users[indexPath.row];
        cell.user = user;
        DebugLog(@"cell user %@", user);
        [cell setValues];
        cell.follow.hidden = YES;
        cell.navigationController = self.navigationController;
        return cell;
    } else {
        static NSString * reuseIdentifier = @"NoResultsCell";
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.explanation.text = @"No people found";
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    } else {
        return 205;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [users count];
    } else {
        if (showNoResultsMessage == YES) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (void)getUsersByName:(NSString *)searchText {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/search?search=%@", searchText] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [users removeAllObjects];
        [users addObjectsFromArray:mappingResult.array];
        if ([users count] == 0) {
            showNoResultsMessage = YES;
        } else {
            showNoResultsMessage = NO;
        }
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

/*
- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 1) {
        [self getUsersByName:searchText];
    } else {
        [users removeAllObjects];
        [_tableView reloadData];
    }
}
*/

- (void)purge {
    [users removeAllObjects];
    [_tableView reloadData];
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidStartBrowsingSearchTable object:nil];
}

@end
