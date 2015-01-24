#import "DGExploreCategoriesViewController.h"
#import "CategoryCell.h"
#import "ExplorePopularTagsCell.h"
#import "ExploreHighlightsCell.h"
#import "DGCategory.h"
#import "DGGoodListViewController.h"
#import <SAMLoadingView/SAMLoadingView.h>

@implementation DGExploreCategoriesViewController

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.view addSubview:self.loadingView];
    self.title = @"Categories";
    UINib *categoryNib = [UINib nibWithNibName:kCategoryCell bundle:nil];
    [self.tableView registerNib:categoryNib forCellReuseIdentifier:kCategoryCell];

    if (self.exploreHighlights == nil) {
        self.exploreHighlights = [[ExploreHighlightsCell alloc] initWithController:self.navigationController];
    }
    if (self.explorePopularTags == nil) {
        self.explorePopularTags = [[ExplorePopularTagsCell alloc] initWithController:self.navigationController];
    }

    [self.tableView setTableHeaderView:self.exploreHighlights];
    [self.tableView setTableFooterView:self.explorePopularTags];

    self.loadingView = [[SAMLoadingView alloc] initWithFrame:self.view.bounds];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;

    [self getCategories];

    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self setupRefresh];
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

#pragma mark - Custom methods

- (void)setupRefresh {
    self.refreshControl = [[UIRefreshControl alloc] init];
    [self.refreshControl setTintColor:VIVID];
    [self.refreshControl addTarget:self action:@selector(refreshTable)
             forControlEvents:UIControlEventValueChanged];
    [self.tableView addSubview:self.refreshControl];
}

- (void)refreshTable {
    [self getCategories];
    [self.explorePopularTags getTags];
    [self.refreshControl endRefreshing];
}

- (void)getCategories {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        self.categories = [[NSArray alloc] initWithArray:mappingResult.array];
        [self.tableView reloadData];
        [self.loadingView removeFromSuperview];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [self.loadingView removeFromSuperview];
    }];
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"CategoryCell";
    CategoryCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGCategory *category = self.categories[indexPath.row];
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
    return [self.categories count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGCategory *category = self.categories[indexPath.row];

    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    goodListController.category = category;

    [self.navigationController pushViewController:goodListController animated:YES];
}

@end

