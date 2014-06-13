#import "DGViewController.h"
@import MapKit;

@interface DGMapViewController : DGViewController <MKMapViewDelegate> {
    __weak IBOutlet MKMapView *mapView;
}

- (void)addSinglePinForAddress:(NSDictionary *)address;

@end
