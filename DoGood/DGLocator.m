#import "DGLocator.h"

@implementation DGLocator

+ (void)checkLocationAccessWithSuccess:(LocateUserBlock)success failure:(ErrorBlock)failure {

    NSDictionary *unableToLocateErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Enable Location Services.", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Location services permission denied", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Settings > Privacy > Location Services", nil)
    };

    NSError *error = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:unableToLocateErrorInfo];

    if (![CLLocationManager locationServicesEnabled]) {
        failure(error);
        return;
    }

    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusDenied) {
        failure(error);
        return;
    }

    success(YES, @"Woot");

}

@end
