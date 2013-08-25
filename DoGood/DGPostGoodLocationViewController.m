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
    self.tableView.delegate = self;

    DebugLog(@"region %@", region);

    UIImageView *logo = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 50)];
    logo.contentMode = UIViewContentModeCenter;

    logo.image = [UIImage imageNamed:@"PoweredByFoursquare"];
    DebugLog(@"header view %@", self.tableView.tableHeaderView);
    [self.tableView setTableFooterView:logo];
    // [self.tableView setTableHeaderView:searchBar];
    DebugLog(@"header view %@", self.tableView.tableHeaderView);
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView {
    // searchBar.frame = CGRectMake(0, MAX(0, scrollView.contentOffset.y), 320, 44);
    CGRect rect = searchBar.frame;
    rect.origin.y = MIN(0, scrollView.contentOffset.y);
    [scrollView layoutSubviews];
    searchBar.frame = rect;
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
    [self findVenuesAtLocation:[foundLocations lastObject] matchingQuery:nil];
    
    region = [[CLRegion alloc] initCircularRegionWithCenter:userLocation.coordinate radius:750 identifier:@"currentRegion"];
    [locationManager stopUpdatingLocation];
}

#pragma mark - Find locations
- (void)findVenuesAtLocation:(CLLocation *)location matchingQuery:(NSString *)query {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:FOURSQUARE_API_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:@"application/json"];
    DebugLog(@"query %@", query);
    if (query == nil) {
        query = @"";
    }
    DebugLog(@"query %@", query);

    // lat & lng
    NSString *ll = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];

    // version date
    NSDateFormatter* formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyyMMdd"];
    NSString* dateString = [formatter stringFromDate:[NSDate date]];

    // path
    NSString* path = [NSString stringWithFormat:
        @"/v2/venues/search?client_id=%@&client_secret=%@&ll=%@&query=%@&v=%@",
        FOURSQUARE_CLIENT_ID,
        FOURSQUARE_CLIENT_SECRET,
        ll,
        query,
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
        [self findVenuesAtLocation:userLocation matchingQuery:searchText];
        // [self geocodeLocation:searchText];
    } else if (searchText.length == 0) {
        locations = tempLocations;
    } else {
        [locations removeAllObjects];
        [self.tableView reloadData];
    }
}

/*
- (void)geocodeLocation:(NSString *)searchText {
    [geo cancelGeocode];
    // executed on main thread
    DebugLog(@"region outside %@", region);
    [geo geocodeAddressString:searchText inRegion:region completionHandler:^(NSArray *placemarks, NSError *error) {
        if (!error) {
            DebugLog(@"placemarks %@", placemarks);
            CLPlacemark *place = [placemarks objectAtIndex:0];
            DebugLog(@"place %@", place);
            DebugLog(@"region inside %@", region);
            [self findLocations:place.location];
        }
        else {
            DebugLog(@"There was a forward geocoding error\n%@", [error localizedDescription]);
        }
    }];
}
*/

@end
