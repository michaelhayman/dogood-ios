@class DGGoodListViewController;
@interface DGWelcomeViewController : UIViewController {
    __weak IBOutlet UIButton *signInButton;
    __weak IBOutlet UIButton *signUpButton;
    
}
@property (weak, nonatomic) IBOutlet UITextView *welcomeLabel;
@property (weak, nonatomic) DGGoodListViewController* goodList;

@end
