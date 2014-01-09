#import "AuthenticateView.h"
#import "DGSignUpViewController.h"
#import "DGSignInViewController.h"
#import "AuthenticateView.h"

@implementation AuthenticateView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"AuthenticateView" owner:self options:nil];
        [self addSubview:self.view];
    }
    return self;
}

- (void) awakeFromNib {
    [super awakeFromNib];
}

- (IBAction)createAccount:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGSignUpViewController*controller = [storyboard instantiateViewControllerWithIdentifier:@"SignUp"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)signIn:(id)sender {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGSignInViewController*controller = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
    [self.navigationController pushViewController:controller animated:YES];
}

@end