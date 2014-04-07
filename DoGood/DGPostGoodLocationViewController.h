#import <CoreLocation/CoreLocation.h>
@protocol DGPostGoodLocationViewControllerDelegate;
@class FSLocation;

@interface DGPostGoodLocationViewController : UIViewController <CLLocationManagerDelegate, UISearchBarDelegate> {
    NSMutableArray *locations;
    CLLocationManager *locationManager;
    CLLocation *userLocation;
    BOOL located;
    __weak IBOutlet UISearchBar *searchBar;
    __weak IBOutlet UIImageView *logo;
    __weak IBOutlet UITableView *tableView;
}

@property (nonatomic, weak) id<DGPostGoodLocationViewControllerDelegate> delegate;

@end

@protocol DGPostGoodLocationViewControllerDelegate <NSObject>

- (void)childViewController:(DGPostGoodLocationViewController* )viewController
    didChooseLocation:(FSLocation *)location;

@end
