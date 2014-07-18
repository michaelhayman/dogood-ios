#import "DGMessage.h"
#import "TSMessage.h"

@implementation DGMessage

+ (void)showSuccessInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle {
    [TSMessage showNotificationInViewController:viewController title:title subtitle:subtitle type:TSMessageNotificationTypeSuccess];
}

+ (void)showErrorInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle {
    [TSMessage showNotificationInViewController:viewController title:title subtitle:subtitle type:TSMessageNotificationTypeError];
}

+ (void)dismissActiveNotification {
    [TSMessage dismissActiveNotification];
}

@end
