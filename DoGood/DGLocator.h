#import <CoreLocation/CoreLocation.h>

typedef void (^ErrorBlock)(NSError *error);
typedef void (^LocateUserBlock)(BOOL success, NSString *msg);

@interface DGLocator : NSObject {
    NSError *unableToPostError;
}

+ (void)checkLocationAccessWithSuccess:(LocateUserBlock)success failure:(ErrorBlock)failure;

@end
