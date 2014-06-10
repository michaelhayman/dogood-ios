@protocol DGForgotPasswordViewControllerDelegate;

@interface DGForgotPasswordViewController : DGViewController

@property (strong, nonatomic) NSString *signInEmail;
@property (nonatomic, weak) id<DGForgotPasswordViewControllerDelegate> delegate;

@end

@protocol DGForgotPasswordViewControllerDelegate <NSObject>

- (void)childViewController:(DGForgotPasswordViewController* )viewController didReceiveEmail:(NSString *)email;

@end
