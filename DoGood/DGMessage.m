#import "DGMessage.h"
#import <ProgressHUD/ProgressHUD.h>

@implementation DGMessage

+ (void)showSuccessInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle {
    [ProgressHUD showSuccess:[self buildMessage:title withSubmessage:subtitle] Interaction:YES];
}

+ (void)showErrorInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle {
    [ProgressHUD showError:[self buildMessage:title withSubmessage:subtitle] Interaction:YES];
}

+ (void)dismissActiveNotification {
    [ProgressHUD dismiss];
}

+ (NSString *)buildMessage:(NSString *)title withSubmessage:(NSString *)subtitle {
    if (subtitle) {
        return [NSString stringWithFormat:@"%@\n%@", title, subtitle];
    } else {
        return title;
    }
}

@end
