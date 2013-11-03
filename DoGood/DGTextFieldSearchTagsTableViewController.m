#import "DGTextFieldSearchTagsTableViewController.h"
#import "TagCell.h"
#import "DGTag.h"
#import "NoResultsCell.h"

@implementation DGTextFieldSearchTagsTableViewController

- (id)initWithScrolling:(BOOL)reverse {
    self = [super init];
    if (self) {
        tags = [[NSMutableArray alloc] init];
        reverseScroll = reverse;
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tags count] == 0) {
        static NSString * reuseIdentifier = @"NoResultsCell";
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
               if (reverseScroll) {
            _tableView.transform = CGAffineTransformMakeRotation(M_PI);
            cell.transform = CGAffineTransformMakeRotation(-M_PI);
               }
        cell.explanation.text = @"No tags found";
        return cell;
    }

    static NSString * reuseIdentifier = @"TagCell";
    TagCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
       if (reverseScroll) {
        _tableView.transform = CGAffineTransformMakeRotation(-M_PI);
           cell.transform = CGAffineTransformMakeRotation(M_PI);
       }
    DGTag *tag = tags[indexPath.row];
    cell.taggage = tag;
    // cell.disableSelection = YES;
    cell.navigationController = self.navigationController;
    [cell setValues];
    // cell.follow.hidden = YES;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([tags count] == 0) {
       return 204;
    }
    return 30;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [tags count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)getTagsByName:(NSString *)searchText {
    NSDictionary *params;
    if (searchText) {
        params = [[NSDictionary alloc] initWithObjectsAndKeys:searchText, @"q", nil];
    } else {
        params = nil;
    }

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/tags/search" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [tags removeAllObjects];
        [tags addObjectsFromArray:mappingResult.array];
        if ([tags count] == 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidNotFindTagsForTextField object:nil];
            [self purge];
        }
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGUser *tag = tags[indexPath.row];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:tag, @"tag", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidSelectTagForTextField object:nil userInfo:userInfo];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    if ([searchText length] > 1) {
        [self getTagsByName:searchText];
    } else {
        [tags removeAllObjects];
        [_tableView reloadData];
    }
}

- (void)purge {
    [tags removeAllObjects];
    [_tableView reloadData];
}

@end
