@interface DGMessage : NSObject

+ (void)showSuccessInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle;
+ (void)showErrorInViewController:(UIViewController *)viewController
                                   title:(NSString *)title
                                subtitle:(NSString *)subtitle;
+ (void)dismissActiveNotification;

@end
