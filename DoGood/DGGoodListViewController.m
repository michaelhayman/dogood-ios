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
        [self setupMenuTitle:@"Good"];
    }

    if (self.category) {
        [goodTableView showTabsWithColor:[self.category rgbColour]];
    } else if (self.color) {
        [self customizeNavColor:self.color];
        [goodTableView showTabsWithColor:self.color];
    } else if (!self.hideTabs) {
        [goodTableView showTabs];
    }

    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView setupRefresh];
    [goodTableView setupInfiniteScroll];
    [self getGood];

    self.navigationItem.rightBarButtonItem = [DGAppearance postBarButtonItemFor:self];
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
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Saved!", nil) subtitle:NSLocalizedString(@"You made some points!", nil) type:TSMessageNotificationTypeSuccess];
}

#pragma mark - Retrieval methods
- (void)getGood {
    NSString *path;
    DebugLog(@"path ...? %@", _path);
    if (self.path) {
        path = self.path;
    } else if (self.category) {
        path = [NSString stringWithFormat:@"/goods?category_id=%@", _category.categoryID];
    } else if (self.goodID) {
        path = [NSString stringWithFormat:@"/goods/%@", _goodID];
    } else if (self.tag) {
        path = [NSString stringWithFormat:@"/goods/tagged?name=%@", [self.tag.name stringByAddingPercentEscapesUsingEncoding: NSUTF8StringEncoding]];
    } else if (self.user) {
        path = [NSString stringWithFormat:@"/goods/followed_by?user_id=%@", self.user.userID];
    } else {
        path = @"/goods";
    }

    if (self.goToSpecificTab) {
        goodTableView.doneGoods = self.showDoneGoods;
    }

    [goodTableView resetGood];
    [goodTableView loadGoodsAtPath:path];
}

@end
