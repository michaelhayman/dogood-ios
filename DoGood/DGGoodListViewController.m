#import "DGGoodListViewController.h"
#import "DGWelcomeViewController.h"
#import "DGUserProfileViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGLocation.h"
#import "DGGoodCommentsViewController.h"

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
    userName.text = [PFUser currentUser].username;
    UILabel *points = (UILabel *)[headerView viewWithTag:202];
    points.text = @"51,500";

    [self getGood];
}

- (void)viewWillAppear:(BOOL)animated {
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

    cell.overviewImage.file = good.image;
    [cell.overviewImage loadInBackground];
    [cell.overviewImage loadInBackground:^(UIImage *image, NSError *error) {
        cell.imageHeight.constant = image.size.height;
    }];
    cell.username.text = good.user.username;
    cell.likes.text = good.location.displayName;
    // UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showComments:)];
    // cell.comment.tag = indexPath.row;
    // UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] init];
    // [imageGesture performSelector:@selector(showComments) withObject:good];
    // [cell.commentsCount setUserInteractionEnabled:YES];
    // [cell.commentsCount addGestureRecognizer:imageGesture];

    // [cell.comment addTarget:self action:@selector(addComment:) forControlEvents:UIControlEventTouchUpInside];
    // [cell.comment performSelector:@selector(addComment:) withObject:good];
    return cell;
}

/*
-(void)addComment:(id)sender {
    DebugLog(@"adding comment");
    UIButton *commentButton = (UIButton *)sender;

    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *comments = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    comments.good = goods[commentButton.tag];
    DebugLog(@"comments good %@", comments.good);
    comments.makeComment = YES;
    [self.navigationController pushViewController:comments animated:YES];
}

-(void)showComments:(id)sender {
    DebugLog(@"adding comment");
    UIButton *commentButton = (UIButton *)sender;
    UIStoryboard *goodS = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodCommentsViewController *comments = [goodS instantiateViewControllerWithIdentifier:@"GoodComments"];
    comments.good = goods[commentButton.tag];
    [self.navigationController pushViewController:comments animated:YES];
}
*/

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
- (void) getGood {
    PFQuery *query = [PFQuery queryWithClassName:@"DGGood"];
    [query includeKey:@"category"];
    [query includeKey:@"user"];
    [query includeKey:@"location"];
    // [query whereKey:@"playerName" equalTo:@"Dan Stemkoski"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (!error) {
            // The find succeeded.
            NSLog(@"Successfully retrieved %d goods", objects.count);
            // Do something with the found objects
            for (PFObject *object in objects) {
                NSLog(@"%@", object.objectId);
            }
            goods = objects;
            [tableView reloadData];
        } else {
            // Log details of the failure
            NSLog(@"Error: %@ %@", error, [error userInfo]);
        }
    }];
}


@end

