#import <CoreLocation/CoreLocation.h>

@interface DGPostGoodLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    __weak IBOutlet UISearchBar *searchBar;
    CLGeocoder *geo;
    CLRegion *region;
}

@end

