#import "DGGoodListViewController.h"
#import "DGWelcomeViewController.h"
#import "GoodCell.h"

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    UINib *nib = [UINib nibWithNibName:@"GoodCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"GoodCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Actions
- (IBAction)signOut:(id)sender {
    [PFUser logOut];
    self.navigationController.navigationBarHidden = YES;
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    self.navigationController.navigationBarHidden = YES;
    [self.navigationController pushViewController:welcomeViewController animated:NO];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodCell"];
    if (indexPath.row == 0) {
        cell.username.text = @"hey";
    } else {
        cell.username.text = @"sup";
    }

    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 573;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return 2;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

@end

