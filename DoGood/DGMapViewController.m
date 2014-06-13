#import "DGMapViewController.h"
@import MapKit;

@interface DGMapViewController ()

@end

@implementation DGMapViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self updateTitleButtons];
    }
    return self;
}

- (void)updateTitleButtons {
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(closeButtonTapped:)];

    self.navigationItem.rightBarButtonItem = doneButton;
}

- (IBAction)closeButtonTapped:(id)sender {
    [self dismissViewControllerAnimated:YES completion:NULL];
}

- (void)addSinglePinForAddress:(NSDictionary *)addressComponents {
    DebugLog(@"address components %@", addressComponents);
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressDictionary:addressComponents completionHandler:^(NSArray *placemarks, NSError *error) {
        if (error) {
            DebugLog(@"couldnt geocode");
            return;
        }
        CLPlacemark *placemark = [placemarks firstObject];
        float spanX = 0.00725;
        float spanY = 0.00725;
        MKCoordinateRegion region;
        region.center.latitude = placemark.location.coordinate.latitude;
        region.center.longitude = placemark.location.coordinate.longitude;
        region.span = MKCoordinateSpanMake(spanX, spanY);
        [mapView setRegion:region animated:NO];

        MKPlacemark *pin = [[MKPlacemark alloc] initWithPlacemark:placemark];
        [mapView addAnnotation:pin];
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
