@class DGLoadingView;
@class GoodTableView;
#import <CoreLocation/CoreLocation.h>

@interface DGGoodListNearbyViewController : UIViewController <CLLocationManagerDelegate> {
    // goods
    DGLoadingView *loadingView;

    // location
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    UIRefreshControl *refreshControl;
    __weak IBOutlet GoodTableView *goodTableView;
}

@end
