#import "DGPostGoodCategoryViewController.h"
#import "DGCategory.h"
#import "CategoryCell.h"

@interface DGPostGoodCategoryViewController ()

@end

@implementation DGPostGoodCategoryViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Category"];
    UINib *categoryNib = [UINib nibWithNibName:kCategoryCell bundle:nil];
    [self.tableView registerNib:categoryNib forCellReuseIdentifier:kCategoryCell];

    // customize look
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    [self getCategories];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // hit up the cache only
    return [categories count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"CategoryCell";
    CategoryCell *cell = [tableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGCategory *category = categories[indexPath.row];
    cell.category = category;
    [cell setValues];
    cell.navigationController = self.navigationController;
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    DGCategory *category = categories[indexPath.row];

    if ([self.delegate respondsToSelector:@selector(childViewController:didChooseCategory:)]) {
        [self.delegate childViewController:self didChooseCategory:category];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)dealloc {
}

- (void)getCategories {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        categories = [[NSArray alloc] initWithArray:mappingResult.array];
        [self.tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end
