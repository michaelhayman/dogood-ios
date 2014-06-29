#import "DGNotification.h"
#import "URLHandler.h"

static NSString * DGNormalizedDeviceTokenStringWithDeviceToken(id deviceToken) {
    if ([deviceToken isKindOfClass:[NSData class]]) {
        const unsigned *bytes = [(NSData *)deviceToken bytes];
        return [NSString stringWithFormat:@"%08x%08x%08x%08x%08x%08x%08x%08x", ntohl(bytes[0]), ntohl(bytes[1]), ntohl(bytes[2]), ntohl(bytes[3]), ntohl(bytes[4]), ntohl(bytes[5]), ntohl(bytes[6]), ntohl(bytes[7])];
    } else {
        return [[[[deviceToken description] uppercaseString] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
    }
}

@implementation DGNotification

+ (void)promptForNotifications {
    [self apnsPrompt];
}

+ (void)reregisterForNotifications {
    if ([self notifiable]) {
        DebugLog(@"notifiable");
        [self apnsPrompt];
    } else {
        DebugLog(@"not notifiable yet");
    }
}

+ (void)apnsPrompt {
    [[UIApplication sharedApplication] registerForRemoteNotificationTypes:(UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeBadge | UIRemoteNotificationTypeSound)];
}

+ (BOOL)notifiable {
    return [[NSUserDefaults standardUserDefaults] boolForKey:kDGUserCurrentUserNotifiable];
}

+ (void)setNotifiable {
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:kDGUserCurrentUserNotifiable];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

+ (void)registerToken:(NSData *)token {
    NSString *deviceToken = DGNormalizedDeviceTokenStringWithDeviceToken(token);
    [[RKObjectManager sharedManager].HTTPClient putPath:[NSString stringWithFormat:@"/devices/%@", deviceToken] parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        DebugLog(@"Registration success: %@", responseObject);
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        DebugLog(@"Registration error: %@", error);
    }];
}

+ (void)disableNotifications {
    DebugLog(@"disable notifications");
}

+ (void)handleNotification:(NSDictionary *)notification {
    if ([UIApplication sharedApplication].applicationState == UIApplicationStateActive) {
        DebugLog(@"Inside notification.");
    } else {
        DebugLog(@"Outside notification.");
        [self showContent:notification];
    }
    [self setBadge:notification];
}

+ (void)showContent:(NSDictionary *)notification {
    NSString *urlString = [notification objectForKey:@"url"];
    NSURL *url = [NSURL URLWithString:urlString];
    URLHandler *handler = [[URLHandler alloc] init];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
}

+ (void)setBadge:(NSDictionary *)notification {
    NSString *badge = [[notification objectForKey:@"aps"] objectForKey:@"badge"];
    DebugLog(@"Bumping badge number to: %@", badge);
    [UIApplication sharedApplication].applicationIconBadgeNumber = [badge integerValue];
}

@end
