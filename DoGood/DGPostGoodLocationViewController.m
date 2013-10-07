#import "DGPostGoodLocationViewController.h"
#import "FSLocation.h"
#import "AFNetworking.h"

@interface DGPostGoodLocationViewController ()

@end

@implementation DGPostGoodLocationViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Location"];

    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
    locations = [[NSMutableArray alloc] init];

    logo.contentMode = UIViewContentModeCenter;

    searchBar.delegate = self;

    logo.image = [UIImage imageNamed:@"PoweredByFoursquare"];
    [tableView setTableFooterView:logo];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self.view endEditing:YES];
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
    [locationManager stopUpdatingLocation];
    [self findVenuesAtLocation:[foundLocations lastObject] matchingQuery:nil];
}

#pragma mark - Find locations
- (void)findVenuesAtLocation:(CLLocation *)location matchingQuery:(NSString *)query {
    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:FOURSQUARE_API_URL];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    [client setDefaultHeader:@"Accept" value:@"application/json"];

    // query
    if (query == nil) {
        query = @"";
    }

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
    path = [path stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding];

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
            location.displayName = element[@"name"];
            location.lat = [NSNumber numberWithDouble:[(NSString*)(element[@"location"][@"lat"]) doubleValue]];
            location.lng = [NSNumber numberWithDouble:[(NSString*)(element[@"location"][@"lng"]) doubleValue]];
            location.address = (NSString*)(element[@"location"][@"address"]);
            DebugLog(@"category %@", element[@"categories"]);
            if ([element[@"categories"] count] > 0) {
                location.imageURL = [NSString stringWithFormat:@"%@%@%@", element[@"categories"][0][@"icon"][@"prefix"], @"88", element[@"categories"][0][@"icon"][@"suffix"]];
            }
            DebugLog(@"location %@ %@ %@", location.displayName, location.lat, location.lng);
            [locations addObject:location];
        }
        [tableView reloadData];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"The operation failed.");
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

- (UITableViewCell *)tableView:(UITableView *)thisTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"location";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    FSLocation *location = locations[indexPath.row];
    cell.textLabel.text = location.displayName;
    cell.detailTextLabel.text = location.address;

    [cell.imageView setImageWithURL:[NSURL URLWithString:location.imageURL] placeholderImage:[UIImage imageNamed:@"EmptyLocation"]];
    cell.imageView.backgroundColor = [UIColor lightGrayColor];
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    FSLocation *location = locations[indexPath.row];
    DebugLog(@"location %@ %@ %@", location.displayName, location.lat, location.imageURL);
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
    } else if (searchText.length == 0) {
        locations = tempLocations;
        [tableView reloadData];
    } else {
        [locations removeAllObjects];
        [tableView reloadData];
    }
}

@end
