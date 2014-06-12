#import "DGUserListViewController.h"
#import "UserCell.h"
#import "NoResultsCell.h"
#import <SAMLoadingView/SAMLoadingView.h>

@interface DGUserListViewController ()

@end

@implementation DGUserListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:[self.query capitalizedString]];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];
    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];

    UIRefreshControl *refreshControl = [UIRefreshControl new];
    refreshControl.tintColor = VIVID;

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];

    showNoResultsMessage = NO;

    loadingView = [[SAMLoadingView alloc] initWithFrame:tableView.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    /*
    if ([self.query isEqualToString:@"following"]) {
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getUsers) name:DGUserDidChangeFollowOnUser object:nil];
    }
    */
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self getUsers];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)dealloc {
}

- (void)refresh:(UIRefreshControl *)refreshControl {
    [self getUsers];
    [refreshControl endRefreshing];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        static NSString * reuseIdentifier = @"UserCell";
        UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        DGUser *user = users[indexPath.row];
        cell.user = user;
        DebugLog(@"user %@", user);
        [cell setValues];
        cell.navigationController = self.navigationController;
        return cell;
    } else {
        static NSString * reuseIdentifier = kNoResultsCell;
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell setHeading:@"No users found" explanation:@"" andImage:[UIImage imageNamed:@"NoPeople"]];
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        return 60;
    } else {
        return kNoResultsCellHeight;
    }
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return [users count];
    } else {
        if (showNoResultsMessage == YES) {
            tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
            return 1;
        } else {
            tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
            return 0;
        }
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - Retrieval methods
- (void)getUsers {
    [tableView addSubview:loadingView];

    [[RKObjectManager sharedManager] getObjectsAtPath:[NSString stringWithFormat:@"/users/%@?type=%@&id=%@", self.query, self.type, self.typeID] parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        users = [[NSArray alloc] initWithArray:mappingResult.array];
        if ([users count] == 0)  {
            showNoResultsMessage = YES;
        } else {
            showNoResultsMessage = NO;
        }
        [tableView reloadData];
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
    }];
}

@end
