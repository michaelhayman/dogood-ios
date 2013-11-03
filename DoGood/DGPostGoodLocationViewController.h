#import <CoreLocation/CoreLocation.h>

@interface DGPostGoodLocationViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UITableView *tableView;
}

@end

