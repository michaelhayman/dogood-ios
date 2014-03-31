#import "DGGoodListNearbyViewController.h"
#import "DGAppearance.h"
#import "GoodTableView.h"
#import <ProgressHUD/ProgressHUD.h>

@interface DGGoodListNearbyViewController ()

@end

@implementation DGGoodListNearbyViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];

    [self setupMenuTitle:@"Nearby"];

    goodTableView.navigationController = self.navigationController;
    goodTableView.parent = self;
    [goodTableView showTabs];

    [self setupRefresh];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self kickOffLocation];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [ProgressHUD dismiss];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)kickOffLocation {
    [goodTableView resetGood];
    [ProgressHUD show:@"Locating..."];
    if (![CLLocationManager locationServicesEnabled]) {
        [ProgressHUD showError:@"Enable Location Services.\n\nSettings > Privacy > Location Services"];
        DebugLog(@"location services not enabled");
        return;
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        [ProgressHUD showError:@"Enable Location Services for Do Good.\n\nSettings > Privacy > Location Services"];
        DebugLog(@"location services access denied");
        return;
    }
    [ProgressHUD dismiss];

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
    [goodTableView addSubview:refreshControl];
}

- (void)refresh:(UIRefreshControl *)refreshCtrl {
    [self kickOffLocation];
    [refreshCtrl endRefreshing];
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
    [goodTableView resetGood];
    [goodTableView loadGoodsAtPath:path];
}

@end
