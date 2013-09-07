#import <CoreLocation/CoreLocation.h>

@interface DGPostGoodLocationViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    IBOutlet UISearchBar *searchBar;
    CLGeocoder *geo;
    CLRegion *region;
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UITableView *tableView;
}

@end

