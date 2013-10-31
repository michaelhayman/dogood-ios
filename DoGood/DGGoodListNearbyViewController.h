@class DGGoodListViewController;
@class DGLoadingView;
#import <CoreLocation/CoreLocation.h>

@interface DGGoodListNearbyViewController : UIViewController <CLLocationManagerDelegate> {

    // goods
    __weak IBOutlet UITableView *tableView;
    DGGoodListViewController *goodList;
    DGLoadingView *loadingView;

    // location
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    UIRefreshControl *refreshControl;
}

@end
