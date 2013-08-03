#import <UIKit/UIKit.h>
#import <Parse/Parse.h>
@class DGLogInViewController;
@class DGSignUpViewController;

@interface DGWelcomeViewController : UIViewController <PFLogInViewControllerDelegate, PFSignUpViewControllerDelegate> {
    DGLogInViewController *logInViewController;
    DGSignUpViewController *signUpViewController;
}
@property (weak, nonatomic) IBOutlet UITextView *welcomeLabel;

@end
