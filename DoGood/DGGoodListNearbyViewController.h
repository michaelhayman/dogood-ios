@class GoodTableView;
#import <CoreLocation/CoreLocation.h>

@interface DGGoodListNearbyViewController : UIViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    UIRefreshControl *refreshControl;
    __weak IBOutlet GoodTableView *goodTableView;
}

@end
