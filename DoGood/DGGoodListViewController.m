#import "DGGoodListViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGLocation.h"
#import "DGWelcomeViewController.h"

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Do Good";

    [self addMenuButton:@"MenuFromHomeIcon" withTapButton:@"MenuFromHomeIconTap"];

    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"GoodCell"];

    [[NSBundle mainBundle] loadNibNamed:@"UserOverview" owner:self options:nil];
    [tableView setTableHeaderView:headerView];

    UILabel *userName = (UILabel *)[headerView viewWithTag:201];
    userName.text = [DGUser currentUser].username;
    UILabel *points = (UILabel *)[headerView viewWithTag:202];
    points.text = @"51,500";

    [self getGood];
}

- (void)viewWillAppear:(BOOL)animated {
    if (![[DGUser currentUser] isSignedIn]) {
        UIStoryboard *storyboard;
        storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
        UINavigationController *navController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
        [self presentViewController:navController animated:NO completion:nil];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"GoodCell"];
    // all this stuff can move to the cell...
    DGGood * good = goods[indexPath.row];
    cell.good = good;
    cell.navigationController = self.navigationController;
    cell.description.text = good.caption;

    cell.overviewImage.image = good.image;

    cell.username.text = good.user.username;
    cell.likes.text = good.location.displayName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 573;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [goods count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}


#pragma mark - Retrieval methods
- (void)getGood {
}

@end

