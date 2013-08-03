#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DGPostGoodLocationViewController : UITableViewController <UITableViewDelegate, UITableViewDataSource, CLLocationManagerDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
}

@end

