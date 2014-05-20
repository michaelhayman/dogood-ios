@import CoreLocation;

@class GoodTableView;

@interface DGGoodListNearbyViewController : DGViewController <CLLocationManagerDelegate> {
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    UIRefreshControl *refreshControl;
    __weak IBOutlet GoodTableView *goodTableView;
    BOOL initialized;
    BOOL foundLocation;
}

@end
