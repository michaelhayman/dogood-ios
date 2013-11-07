#import "DGGoodListNearbyViewController.h"
#import "DGGoodListViewController.h"
#import "DGAppearance.h"
#import "DGLoadingView.h"
#import "UIScrollView+SVInfiniteScrolling.h"

@interface DGGoodListNearbyViewController ()

@end

@implementation DGGoodListNearbyViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupMenuTitle:@"Nearby"];

    goodList = [[DGGoodListViewController alloc] init];
    goodList.loadController = self.navigationController;
    tableView.dataSource = goodList;
    tableView.delegate = goodList;
    goodList.tableView = tableView;
    [goodList initializeTable];
    [self setupRefresh];
    [self setupInfiniteScroll];
    [self kickOffLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)kickOffLocation {
    [goodList.loadingView startLoading];
    [goodList resetGood];
    if (![CLLocationManager locationServicesEnabled]) {
        [goodList.loadingView loadingFailed];
        [goodList.loadingView changeMessage:@"Enable Location Services.\n\nSettings > Privacy > Location Services"];
        DebugLog(@"location services not enabled");
        return;
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [goodList.loadingView loadingFailed];
        [goodList.loadingView changeMessage:@"Enable Location Services for Do Good.\n\nSettings > Privacy > Location Services"];
        DebugLog(@"location services access denied");
        return;
    }
    [goodList.loadingView loadingSucceeded];

    DebugLog(@"location services enabled");

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

- (BOOL)locationPossible {
   return [CLLocationManager locationServicesEnabled] &&
    ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusDenied);
}

- (void)setupRefresh {
    refreshControl = [UIRefreshControl new];

    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    refreshControl.tintColor = COLOUR_GREEN;
    [tableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshCtrl {
    [self kickOffLocation];
    [refreshCtrl endRefreshing];
}

- (void)removeRefresh {
    [refreshControl removeFromSuperview];
}

- (void)setupInfiniteScroll {
    __weak DGGoodListNearbyViewController *weakSelf = self;
    __weak DGGoodListViewController *weakGoodList = goodList;
    __weak UITableView *weakTableView = tableView;

    [tableView addInfiniteScrollingWithActionHandler:^{
        __strong DGGoodListNearbyViewController *strongSelf = weakSelf;
        __strong DGGoodListViewController *strongGoodList = weakGoodList;
        __strong UITableView *strongTableView = weakTableView;
        if ([strongSelf locationPossible] && strongGoodList.path) {
            [strongGoodList loadMoreGood];
        }
        [strongTableView.infiniteScrollingView stopAnimating];
    }];
}

#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)foundLocations {
    userLocation = [foundLocations lastObject];
    [locationManager stopUpdatingLocation];
    [self findGoodAtLocation:[foundLocations lastObject] matchingQuery:nil];
}

- (void)dealloc {
}

#pragma mark - Good Listings
- (void)findGoodAtLocation:(CLLocation *)location matchingQuery:(NSString *)query {
    NSString *path = [NSString stringWithFormat:@"/goods/nearby?lat=%f&lng=%f", location.coordinate.latitude, location.coordinate.longitude];
    goodList.path = path;
    [goodList reloadGood];
}

@end
