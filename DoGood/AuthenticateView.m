#import "AuthenticateView.h"
#import "DGSignUpViewController.h"
#import "DGSignInViewController.h"
#import "AuthenticateView.h"

@implementation AuthenticateView

- (id)initWithCoder:(NSCoder *)coder {
    self = [super initWithCoder:coder];
    if (self) {
        [self initialize];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initialize];
    }
    return self;
}

- (void)initialize {
    [[NSBundle mainBundle] loadNibNamed:@"AuthenticateView" owner:self options:nil];
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.backgroundColor = [UIColor whiteColor];
    self.opaque = YES;
    self.contentMode = UIViewContentModeRedraw;

    [self addSubview:self.view];
    [self layoutSubviews];
    // [self.view setTranslatesAutoresizingMaskIntoConstraints:NO];
}

+ (BOOL)translatesAutoresizingMaskIntoConstraints {
    return YES;
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