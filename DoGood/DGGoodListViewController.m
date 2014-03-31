#import "DGGoodListViewController.h"
#import "DGPostGoodViewController.h"
#import "GoodCell.h"
#import "DGGood.h"
#import "DGTag.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "UserOverview.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import "DGAppearance.h"
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
        [self setupMenuTitle:[self.tag hashifiedName]];
    } else if (self.path) {
        [self setupMenuTitle:self.titleForPath];
    } else {
        [self setupMenuTitle:@"Good Done"];
        [self addMenuButton:@"icon_menu" withTapButton:@"icon_menu"];
    }

    if (self.category) {
        [goodTableView showTabsWithColor:[self.category rgbColour]];
    } else {
        [goodTableView showTabs];
    }

    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView setupRefresh];
    [goodTableView setupInfiniteScroll];
    [self getGood];

    [self setupUserPoints];
}

- (IBAction)postGood:(id)sender {
    URLHandler *handler = [[URLHandler alloc] init];
    NSURL *url = [NSURL URLWithString:@"dogood://goods/new"];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
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
    [[NSNotificationCenter defaultCenter] addObserver:userView selector:@selector(setContent) name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayPostSuccessMessage) name:DGUserDidPostGood object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getGood) name:DGUserDidPostGood object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:userView name:DGUserDidSignInNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidPostGood object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.category) {
        self.navigationController.navigationBar.barTintColor = [self.category rgbColour];
    } else {
        self.navigationController.navigationBar.barTintColor = VIVID;
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)displayPostSuccessMessage {
    [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Saved!", nil) subtitle:NSLocalizedString(@"You made some points!", nil) type:TSMessageNotificationTypeSuccess];
}

- (void)setupUserPoints {
    /*
    if (_category == nil && _tag == nil && _path == nil && REWARDS_ENABLED) {
        userView = [[UserOverview alloc] initWithController:self.navigationController];
        [_tableView setTableHeaderView:userView];
    }
    */
}

#pragma mark - Retrieval methods
- (void)getGood {
    NSString *path;
    DebugLog(@"path ...? %@", _path);
    if (_path) {
        path = _path;
    } else if (_category) {
        path = [NSString stringWithFormat:@"/goods?category_id=%@", _category.categoryID];
    } else if (_goodID) {
        path = [NSString stringWithFormat:@"/goods/%@", _goodID];
    } else if (_tag) {
        path = [NSString stringWithFormat:@"/goods/tagged?id=%@&name=%@", _tag.tagID, _tag.name];
    } else {
        path = @"/goods";
    }

    [goodTableView resetGood];
    [goodTableView loadGoodsAtPath:path];
}

@end
