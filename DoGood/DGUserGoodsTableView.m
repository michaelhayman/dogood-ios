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
        cell.sectionName.text = [NSString stringWithFormat:@"Followed %@ good %@", self.user.followed_goods_count, [DGAppearance pluralizeString:@"deed" basedOnNumber:self.user.followed_goods_count]];
        if ([self.user hasFollowedGoods]) {
            cell.icon.image = [UIImage imageNamed:@"ProfileFollowed"];
            [cell enable];
        } else {
            cell.icon.image = [UIImage imageNamed:@"ProfileFollowedOff"];
            [cell disable];
        }
    }
    if (indexPath.section == nominationsFor) {
        cell.sectionName.text = [NSString stringWithFormat:@"Nominated for %@ good %@", self.user.nominations_for_user_goods_count, [DGAppearance pluralizeString:@"deed" basedOnNumber:self.user.nominations_for_user_goods_count]];
        if ([self.user hasPostedNominations]) {
            cell.icon.image = [UIImage imageNamed:@"ProfileNominated"];
            [cell enable];
        } else {
            [cell disable];
            cell.icon.image = [UIImage imageNamed:@"ProfileNominatedOff"];
        }
    }
    if (indexPath.section == votes) {
        cell.sectionName.text = [NSString stringWithFormat:@"Voted for %@ good %@", self.user.voted_goods_count, [DGAppearance pluralizeString:@"deed" basedOnNumber:self.user.voted_goods_count]];
        if ([self.user hasVotes]) {
            cell.icon.image = [UIImage imageNamed:@"ProfileVoted"];
            [cell enable];
        } else {
            cell.icon.image = [UIImage imageNamed:@"ProfileVotedOff"];
            [cell disable];
        }
    }
    if (indexPath.section == nominationsBy) {
        cell.sectionName.text = [NSString stringWithFormat:@"Posted %@ %@", self.user.nominations_by_user_goods_count, [DGAppearance pluralizeString:@"nomination" basedOnNumber:self.user.nominations_by_user_goods_count]];
        if ([self.user hasBeenNominated]) {
            cell.icon.image = [UIImage imageNamed:@"ProfileNominationsPosted"];
            [cell enable];
        } else {
            cell.icon.image = [UIImage imageNamed:@"ProfileNominationsPostedOff"];
            [cell disable];
        }
    }
    if (indexPath.section == helpWanted) {
        cell.sectionName.text = [NSString stringWithFormat:@"Asked for help %@ %@", self.user.help_wanted_by_user_goods_count, [DGAppearance pluralizeString:@"time" basedOnNumber:self.user.help_wanted_by_user_goods_count]];
        if ([self.user hasPostedHelpWantedGoods]) {
            cell.icon.image = [UIImage imageNamed:@"ProfileHelpWanted"];
            [cell enable];
        } else {
            cell.icon.image = [UIImage imageNamed:@"ProfileHelpWantedOff"];
            [cell disable];
        }
    }
    return cell;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 55;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (self.user) {
        return numUserGoodsSections;
    } else {
        return 0;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    goodListController.hideTabs = YES;

    if (indexPath.section == follows) {
        goodListController.path = [NSString stringWithFormat:@"/goods/followed_by?user_id=%@", self.user.userID];
        goodListController.titleForPath = @"Follows";
    }

    if (indexPath.section == nominationsFor) {
        goodListController.path = [NSString stringWithFormat:@"/goods/nominations_for?user_id=%@", self.user.userID];
        goodListController.titleForPath = @"Nominated For";
    }

    if (indexPath.section == nominationsBy) {
        goodListController.path = [NSString stringWithFormat:@"/goods/nominations_by?user_id=%@", self.user.userID];
        goodListController.titleForPath = @"Nominated";
    }

    if (indexPath.section == helpWanted) {
        goodListController.path = [NSString stringWithFormat:@"/goods/help_wanted_by?user_id=%@", self.user.userID];
        goodListController.titleForPath = @"Help Wanted";
    }

    if (indexPath.section == votes) {
        goodListController.path = [NSString stringWithFormat:@"/goods/voted_by?user_id=%@", self.user.userID];
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
