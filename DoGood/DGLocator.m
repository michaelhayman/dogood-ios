#import "DGLocator.h"
#import <ProgressHUD/ProgressHUD.h>

@implementation DGLocator

+ (void)setupErrors {
}

+ (void)checkLocationAccessWithSuccess:(LocateUserBlock)success failure:(ErrorBlock)failure {

    NSError *error;
    NSDictionary *unableToPostErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Enable Location Services.", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Location services permission denied", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Settings > Privacy > Location Services", nil)
    };

    error = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:unableToPostErrorInfo];

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
