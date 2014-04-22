@class GoodTableView;
#import <CoreLocation/CoreLocation.h>

@interface DGGoodListNearbyViewController : DGViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    UIRefreshControl *refreshControl;
    __weak IBOutlet GoodTableView *goodTableView;
    BOOL initialized;
}

@end
