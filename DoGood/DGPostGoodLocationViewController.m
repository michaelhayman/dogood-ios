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
    [locationManager stopUpdatingLocation];
}

#pragma mark - Find locations
- (void)findLocations:(CLLocation *)location {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:@"https://api.foursquare.com"];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    NSString *ll = [NSString stringWithFormat:@"%f,%f", location.coordinate.latitude, location.coordinate.longitude];
    NSString* path = [NSString stringWithFormat:
        @"/v2/venues/search?client_id=%@&client_secret=%@&ll=%@&v=%@",
        @"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII",
        @"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP",
        //@"40.7,-74",
        ll,
        @"20130803"];
    DebugLog(@"path 1 %@", path);

    [client getPath:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSString *responseStr = [[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding];
        DebugLog(@"Request Successful, response '%@'", responseStr);
        NSError *error;
        NSDictionary* jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        NSArray *response = jsonFromData[@"response"][@"venues"];
        [locations removeAllObjects];

        for (NSDictionary *element in response) {
            FSLocation * location = [FSLocation new];
            location.displayName = element[@"name"];
            // location.point = [PFGeoPoint geoPointWithLatitude:[element[@"location"][@"lat"] floatValue] longitude:[element[@"location"][@"lng"] floatValue]];
            [locations addObject:location];
            // DebugLog(@"location %f", location.point.latitude);
            // DebugLog(@"location %f", location.point.longitude);
        }
        [self.tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSDictionary* jsonFromData = (NSDictionary*)[NSJSONSerialization JSONObjectWithData:operation.responseData options:NSJSONReadingMutableContainers error:&error];
        DebugLog(@"failure %@", jsonFromData);
    }];
}

#pragma mark - UITableView delegates & data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // hit up the cache only
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

@end
