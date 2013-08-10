#import <UIKit/UIKit.h>
@class DGLogInViewController;
@class DGSignUpViewController;

@interface DGWelcomeViewController : UIViewController {
    DGLogInViewController *logInViewController;
    DGSignUpViewController *signUpViewController;
}
@property (weak, nonatomic) IBOutlet UITextView *welcomeLabel;

@end
