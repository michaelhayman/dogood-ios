#import "DGShareRankPopupViewController.h"
#import "UIViewController+MJPopupViewController.h"
#import <ProgressHUD/ProgressHUD.h>

@interface DGShareRankPopupViewController ()
    @property (weak, nonatomic) IBOutlet UIImageView *teaser;
    @property (weak, nonatomic) IBOutlet UILabel *heading;
    @property (weak, nonatomic) IBOutlet UITextView *instructions;
    @property (weak, nonatomic) IBOutlet UIButton *actionButton;
@end

@implementation DGShareRankPopupViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setStyle];
    [self setContents];
}

- (void)setStyle {
    if (![[DGUser currentUser] isSignedIn]) {
        self.heading.text = @"Sign Up & Get a Badge!";
        self.instructions.text = @"Get a badge of honors to encourage others when you start doing good.";
        [self.actionButton setTitle:@"Join or Sign In" forState:UIControlStateNormal];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)setContents {
}

- (void)dealloc {
}

- (IBAction)close:(id)sender {
    [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
}

- (IBAction)sendRanking:(id)sender {
    if (![[DGUser currentUser] isSignedIn]) {
        [[DGUser currentUser] authorizeAccess:self.parentViewController];
        // [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
    } else {
        DebugLog(@"send email");
        [ProgressHUD showSuccess:@"Badge sent!"];
        [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
    }
}


@end
