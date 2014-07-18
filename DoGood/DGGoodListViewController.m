#import "DGGoodListViewController.h"
#import "DGPostGoodViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGTag.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "DGComment.h"
#import "GoodTableView.h"
#import "URLHandler.h"
#import "DGNominee.h"
#import "DGUserInvitesViewController.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@interface DGGoodListViewController ()

@end

@implementation DGGoodListViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    if (self.category) {
        [self setupMenuTitle:self.category.name];
        [self updateTitleColor:[self.category rgbColour]];
    } else if (self.tag) {
        [self setupMenuTitle:[self.tag.name stringByRemovingPercentEncoding]];
    } else if (self.user) {
        [self setupMenuTitle:[self.user full_name]];
    } else if (self.path) {
        [self setupMenuTitle:self.titleForPath];
        [self customizeNavColor:self.color];
    } else {
        // single good
        [self setupMenuTitle:@"Good"];
    }

    if (self.goodID) {
        self.hideTabs = YES;
        if (![self.nominee isDGUser] && [self.goodForInvite.done boolValue]) {
            [self promptToInviteNominee];
        }
    }

    if (!self.hideTabs) {
        if (self.category) {
            [goodTableView showTabsWithColor:[self.category rgbColour]];
        } else if (self.color) {
            [self customizeNavColor:self.color];
            [goodTableView showTabsWithColor:self.color];
        }
        else {
            [goodTableView showTabs];
        }
    }

    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView setupRefresh];
    [goodTableView setupInfiniteScroll];
    [self getGood];

    self.navigationItem.rightBarButtonItem = [DGAppearance postBarButtonItemFor:self];
}

- (void)promptToInviteNominee {
    NSString *actionTitle = @"Invite";
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"Invite %@", self.nominee.full_name] message:@"Invite your nominee to join Do Good?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[actionTitle] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             DebugLog(@"Cancelled");
         } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:actionTitle]) {
             [self inviteNominee];
         }
    }];
}

- (void)inviteNominee {
    if ([self.goodForInvite.done boolValue] && !self.nominee.user_id) {
        DebugLog(@"nominated");
        invites = [[DGUserInvitesViewController alloc] init];
        invites.parent = (UIViewController *)self;
        NSString *body;
        if ([self.nominee hasValidEmail]) {
            body = [self.nominee inviteTextForPost:self.goodForInvite];
            invites.isHTML = YES;
            [invites setCustomText:body withSubject:@"You've been nominated for a good deed" toRecipient:self.nominee.email];
            [invites sendViaEmail:nil];
        } else {
            body = @"I've nominated you on Do Good.  Download the app at http://www.dogood.mobi/ and earn rewards for doing good!";
            [invites setCustomText:body withSubject:@"You've been nominated for a good deed" toRecipient:self.nominee.phone];
            [invites sendViaText:nil];
        }
    } else {
        DebugLog(@"not nominated");
    }
}

- (IBAction)postGood:(id)sender {
    if ([[DGUser currentUser] authorizeAccess:self.navigationController.visibleViewController]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
        DGPostGoodViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PostGood"];
        controller.category = self.category;
        controller.doneGoods = goodTableView.doneGoods;
        [self.navigationController pushViewController:controller animated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)dealloc {
    DebugLog(@"dealloc called");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPostSuccessMessage) name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGood) name:DGUserDidPostGood object:nil];
    [[DGTracker sharedTracker] trackScreen:@"Good List"];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidPostGood object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.category) {
        [self customizeNavColor:[self.category rgbColour]];
    } else if (self.color) {
        [self customizeNavColor:self.color];
    } else {
        [self resetToDefaultNavColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)displayPostSuccessMessage {
    [DGMessage showSuccessInViewController:self.navigationController title:NSLocalizedString(@"Saved!", nil) subtitle:NSLocalizedString(@"You made some points!", nil)];
}

#pragma mark - Retrieval methods
- (void)getGood {
    NSString *path;
    DebugLog(@"path ...? %@", _path);
    if (self.path) {
        path = self.path;
    } else if (self.goodID) {
        path = [NSString stringWithFormat:@"/goods/%@", _goodID];
    } else if (self.category) {
        path = [NSString stringWithFormat:@"/goods?category_id=%@", _category.categoryID];
    } else if (self.tag) {
        path = [NSString stringWithFormat:@"/goods/tagged?name=%@", [self.tag.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    } else if (self.user) {
        path = [NSString stringWithFormat:@"/goods/followed_by?user_id=%@", self.user.userID];
    } else {
        path = @"/goods";
    }

    [goodTableView resetGood];
    [goodTableView loadGoodsAtPath:path];
}

@end
