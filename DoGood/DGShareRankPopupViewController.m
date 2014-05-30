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
        self.instructions.text = @"Get your badge of honor by nominating others and posting good things to do.";
        [self.actionButton setTitle:@"Join or Sign In" forState:UIControlStateNormal];
    } else if ([self.user isCurrentUser]) {
        self.actionButton.hidden = YES;
    } else {
        self.heading.text = @"Work Hard & Do Good";
        self.instructions.text = [NSString stringWithFormat:@"%@ is working hard to increase their ranking.  Why not give them some encouragement or post something good of your own?", self.user.full_name];
        self.actionButton.hidden = YES;

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
        [[DGUser currentUser] authorizeAccess:self.parent];
        [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
    } else {
        DebugLog(@"send email");
        [ProgressHUD showSuccess:@"Badge sent!"];
        [self dismissPopupViewController:self animationType:MJPopupViewAnimationSlideBottomBottom];
    }
}


@end
