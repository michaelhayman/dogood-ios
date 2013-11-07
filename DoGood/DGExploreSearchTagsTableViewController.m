#import "DGExploreSearchTagsTableViewController.h"
#import "DGTag.h"
#import "TagCell.h"
#import "NoResultsCell.h"
#import "DGGoodListViewController.h"

@implementation DGExploreSearchTagsTableViewController

- (void)viewDidLoad {
    self.title = @"Search Tags";
}

- (id)init {
    self = [super init];
    if (self) {
        showNoResultsMessage = NO;
        tags = [[NSMutableArray alloc] init];
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(emptyTable) name:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)dealloc {
    DebugLog(@"dealloc..");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewDidDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)emptyTable {
    [tags removeAllObjects];
    [self.tableView reloadData];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"TagCell";
        TagCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGTag *tag = tags[indexPath.row];
        cell.taggage = tag;
        [cell setValues];
        return cell;
   } else {
        static NSString * reuseIdentifier = @"NoResultsCell";
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.explanation.text = @"No tags found";
        return cell;
   }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 44;
    } else {
        return 205;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [tags count];
    } else {
        if (showNoResultsMessage == YES) {
            return 1;
        } else {
            return 0;
        }
    }
}

- (void)tableView:(UITableView *)aTableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        DebugLog(@"push it...");
        DGTag * tag = [tags objectAtIndex:indexPath.row];
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
        controller.tag = tag;
        [self.navigationController pushViewController:controller animated:YES];
    }
    [aTableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - Tag method
- (void)getTagsByName:(NSString *)searchText {
    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/tags/search?q=%@", searchText] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [tags removeAllObjects];
        [tags addObjectsFromArray:mappingResult.array];
        if ([tags count] == 0) {
            showNoResultsMessage = YES;
        } else {
            showNoResultsMessage = NO;
        }
        DebugLog(@"%@", _tableView);
        [_tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

- (void)purge {
    [tags removeAllObjects];
    [_tableView reloadData];
}

@end
