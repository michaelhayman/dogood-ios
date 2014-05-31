#import "DGExploreCategoriesViewController.h"
#import "CategoryCell.h"
#import "ExplorePopularTagsCell.h"
#import "ExploreHighlightsCell.h"
#import "DGCategory.h"
#import "DGGoodListViewController.h"
#import <SAMLoadingView/SAMLoadingView.h>

@implementation DGExploreCategoriesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:loadingView];
    self.title = @"Categories";
    UINib *categoryNib = [UINib nibWithNibName:kCategoryCell bundle:nil];
    [tableView registerNib:categoryNib forCellReuseIdentifier:kCategoryCell];

    if (exploreHighlights == nil) {
        exploreHighlights = [[ExploreHighlightsCell alloc] initWithController:self.navigationController];
    }
    if (explorePopularTags == nil) {
        explorePopularTags = [[ExplorePopularTagsCell alloc] initWithController:self.navigationController];
    }

    [tableView setTableHeaderView:exploreHighlights];
    [tableView setTableFooterView:explorePopularTags];

    loadingView = [[SAMLoadingView alloc] initWithFrame:self.view.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self stylePage];
    [self getCategories];

    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupRefresh];
}

- (void)setupRefresh {
    refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl setTintColor:VIVID];
    [refreshControl addTarget:self action:@selector(refreshTable)
             forControlEvents:UIControlEventValueChanged];
    [tableView addSubview:refreshControl];
}

- (void)refreshTable {
    [self getCategories];
    [explorePopularTags getTags];
    [refreshControl endRefreshing];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

- (void)dealloc {
    DebugLog(@"dealloc called");
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)stylePage {
}

- (void)getCategories {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        categories = [[NSArray alloc] initWithArray:mappingResult.array];
        [tableView reloadData];
        [loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [loadingView removeFromSuperview];
    }];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"CategoryCell";
    CategoryCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGCategory *category = categories[indexPath.row];
    cell.category = category;
    [cell setValues];
    cell.navigationController = self.navigationController;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [categories count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGCategory *category = categories[indexPath.row];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    goodListController.category = category;

    [self.navigationController pushViewController:goodListController animated:YES];
}

@end

