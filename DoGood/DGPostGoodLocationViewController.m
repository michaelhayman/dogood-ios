#import "DGPostGoodLocationViewController.h"
#import "FSLocation.h"
#import "AFNetworking.h"

@interface DGPostGoodLocationViewController ()

@end

@implementation DGPostGoodLocationViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Location";

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    locations = [[NSMutableArray alloc] init];
    geo = [[CLGeocoder alloc] init];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - CLLocationManager delegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)foundLocations {
    DebugLog(@"array of locations %@", foundLocations);
    userLocation = [foundLocations lastObject];
    [self findLocations:[foundLocations lastObject]];
    
    region = [[CLRegion alloc] initCircularRegionWithCenter:userLocation.coordinate radius:750 identifier:@"currentRegion"];
    [locationManager stopUpdatingLocation];
}

#pragma mark - Find locations
- (void)findLocations:(CLLocation *)location {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:FOURSQUARE_API_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    // lat & lng
    NSString *ll = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];

    // versioning date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];

    // path
    NSString* path = [NSString stringWithFormat:
        @"/v2/venues/search?client_id=%@&client_secret=%@&ll=%@&v=%@",
        FOURSQUARE_CLIENT_ID,
        FOURSQUARE_CLIENT_SECRET,
        ll,
        dateString];
    DebugLog(@"path 1 %@", path);

    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        // is this broken offline?
        // NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        // DebugLog(@"Request Successful, response '%@'", responseStr);
        NSError *error;
        NSDictionary* jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        NSArray *response = jsonFromData[@"response"][@"venues"];
        [locations removeAllObjects];

        for (NSDictionary *element in response) {
            FSLocation * location = [FSLocation new];
            DebugLog(@"location %@", location.displayName);
            location.displayName = element[@"name"];
            // DebugLog(@"location %f", location.point.latitude);
            // DebugLog(@"location %f", location.point.longitude);
            // Parse does this with one object, a 'point'
            // location.point
            // location.lat = [element[@"location"][@"lat"] floatValue];
            // location.lng = [element[@"location"][@"lng"] floatValue];
            [locations addObject:location];
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"the operation failed.");
        // don't output here, it's broken
        // NSDictionary* jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        // DebugLog(@"failure %@", jsonFromData);
    }];
}

#pragma mark - UITableView delegates & data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [locations count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"location";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    FSLocation *location = locations[indexPath.row];
    cell.textLabel.text = location.displayName;
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSLocation *location = locations[indexPath.row];
    NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:location, @"location", nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"DGUserDidUpdateGoodLocation"
                                                        object:nil
                                                      userInfo:userInfo];
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)searchBar:(UISearchBar *)searchBar textDidChange:(NSString *)searchText {
    NSMutableArray *tempLocations = locations;
    if ([searchText length] > 1) {
        // wait a few seconds before doing this
        [self geocodeLocation:searchText];
    } else if (searchText.length == 0) {
        locations = tempLocations;
    } else {
        [locations removeAllObjects];
        [self.tableView reloadData];
    }
}

- (void)geocodeLocation:(NSString *)searchText {
    [geo cancelGeocode];
    // executed on main thread
    [geo geocodeAddressString:searchText inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            CLPlacemark *place = [placemarks objectAtIndex:0];
            [self findLocations:place.location];
        }
        else {
            DebugLog(@"There was a forward geocoding error\n%@", [error localizedDescription]);
        }
    }];
}

@end
