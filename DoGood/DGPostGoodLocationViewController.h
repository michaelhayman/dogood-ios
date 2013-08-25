#import <CoreLocation/CoreLocation.h>

@interface DGPostGoodLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate, UISearchBarDelegate, UIScrollViewDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    IBOutlet UISearchBar *searchBar;
    CLGeocoder *geo;
    CLRegion *region;
}

@end

