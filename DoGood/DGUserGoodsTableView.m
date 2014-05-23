#import "DGUserGoodsTableView.h"
#import "UserGoodCell.h"
#import "DGGoodListViewController.h"
#import "DGUser.h"

@implementation DGUserGoodsTableView

#define kUserGoodCell @"UserGoodCell"

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        self.delegate = self;
        self.dataSource = self;
        self.hidden = YES;
        UINib *nib = [UINib nibWithNibName:kUserGoodCell bundle:nil];
        [self registerNib:nib forCellReuseIdentifier:kUserGoodCell];
        [self setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    }
    return self;
}

- (void)initializeTableWithUser:(DGUser *)user {
    self.hidden = NO;
    self.user = user;
    [self reloadData];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = kUserGoodCell;
    UserGoodCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];

    if (indexPath.section == follows) {
        cell.sectionName.text = [NSString stringWithFormat:@"Followed %@ good deeds", self.user.followed_goods_count];
        cell.icon.image = [UIImage imageNamed:@"profile_followed"];
    }
    if (indexPath.section == nominationsFor) {
        cell.sectionName.text = [NSString stringWithFormat:@"Added %@ good deeds", self.user.nominations_for_user_goods_count];
        cell.icon.image = [UIImage imageNamed:@"profile_nominated"];
    }
    if (indexPath.section == votes) {
        cell.sectionName.text = [NSString stringWithFormat:@"Voted for %@ good deeds", self.user.liked_goods_count];
        cell.icon.image = [UIImage imageNamed:@"profile_voted"];
    }
    if (indexPath.section == nominationsBy) {
        cell.sectionName.text = [NSString stringWithFormat:@"Nominated %@ good deeds", self.user.nominations_by_user_goods_count];
        cell.icon.image = [UIImage imageNamed:@"profile_nominations_posted"];
    }
    if (indexPath.section == helpWanted) {
        cell.sectionName.text = [NSString stringWithFormat:@"Asked for help %@ times", self.user.help_wanted_by_user_goods_count];
        cell.icon.image = [UIImage imageNamed:@"profile_help_wanted"];
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
	switch (section) {
		case follows:
			return [self.user.followed_goods_count intValue] > 0;
			break;
		case nominationsFor:
			return [self.user.nominations_for_user_goods_count intValue] > 0;
			break;
		case votes:
			return [self.user.liked_goods_count intValue] > 0;
			break;
		case nominationsBy:
			return [self.user.nominations_by_user_goods_count intValue] > 0;
			break;
		case helpWanted:
			return [self.user.help_wanted_by_user_goods_count intValue] > 0;
			break;
		default:
            return 0;
			break;
	}
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return numUserGoodsSections;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    goodListController.hideTabs = YES;

    if (indexPath.section == follows) {
        goodListController.path = [NSString stringWithFormat:@"/goods/followed_by?user_id=%@", self.userID];
        goodListController.titleForPath = @"Follows";
    }

    if (indexPath.section == nominationsFor) {
        goodListController.path = [NSString stringWithFormat:@"/goods/nominations_for?user_id=%@", self.userID];
        goodListController.titleForPath = @"Nominated For";
    }

    if (indexPath.section == nominationsBy) {
        goodListController.path = [NSString stringWithFormat:@"/goods/nominations_by?user_id=%@", self.userID];
        goodListController.titleForPath = @"Nominated";
    }

    if (indexPath.section == helpWanted) {
        goodListController.path = [NSString stringWithFormat:@"/goods/help_wanted_by?user_id=%@", self.userID];
        goodListController.titleForPath = @"Help Wanted";
    }

    if (indexPath.section == votes) {
        goodListController.path = [NSString stringWithFormat:@"/goods/liked_by?user_id=%@", self.userID];
        goodListController.titleForPath = @"Votes";
    }

    [self.navigationController pushViewController:goodListController animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (scrollView == self) {
        if (scrollView.contentOffset.y < 0) {
            scrollView.contentOffset = CGPointZero;
        }
    }
}

@end
