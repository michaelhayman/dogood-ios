#import "DGTextFieldSearchPeopleTableViewController.h"
#import "UserCell.h"
#import "NoResultsCell.h"

@implementation DGTextFieldSearchPeopleTableViewController

- (id)init {
    self = [super init];
    if (self) {
        users = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    DGUser *user = users[indexPath.row];
    cell.user = user;
    cell.disableSelection = YES;
    cell.navigationController = self.navigationController;
    [cell setValues];
    cell.follow.hidden = YES;
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

- (void)getUsersByName:(NSString *)searchText {
    NSDictionary *params;
    if (searchText) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:searchText, @"search", nil];
    } else {
        params = nil;
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/users/search" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [users removeAllObjects];
        [users addObjectsFromArray:mappingResult.array];
        if ([users count] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidNotFindPeopleForTextField object:nil];
            [self purge];
        }
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGUser *user = users[indexPath.row];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:user, @"user", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSelectPersonForTextField object:nil userInfo:userInfo];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 1) {
        [self getUsersByName:searchText];
    } else {
        [users removeAllObjects];
        [_tableView reloadData];
    }
}

- (void)purge {
    [users removeAllObjects];
    [_tableView reloadData];
}

@end
