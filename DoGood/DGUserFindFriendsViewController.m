#import "DGUserFindFriendsViewController.h"
#import "DGUserSearchViewController.h"
#import "DGUserSettingsViewController.h"
#import "DGUserSearchAddressBookViewController.h"
#import "DGUserSearchTwitterViewController.h"
#import "DGUserSearchFacebookViewController.h"
#import "DGUserSearchOtherViewController.h"

#import "Arrow.h"
#define kTabSelectionAnimationDuration 0.2

@interface DGUserFindFriendsViewController ()
    @property (nonatomic, strong) DGUserSearchAddressBookViewController *userAddressBook;
    @property (nonatomic, strong) DGUserSearchTwitterViewController *userTwitter;
    @property (nonatomic, strong) DGUserSearchFacebookViewController *userFacebook;
    @property (nonatomic, strong) DGUserSearchOtherViewController *userOther;
@end

@implementation DGUserFindFriendsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Find Friends"];

    if (_userAddressBook == nil) {
        _userAddressBook = [[DGUserSearchAddressBookViewController alloc] initWithNibName:@"SearchUserNetworks" bundle:nil];
    }
    if (_userTwitter == nil) {
        _userTwitter = [[DGUserSearchTwitterViewController alloc] initWithNibName:@"SearchUserNetworks" bundle:nil];
    }
    if (_userFacebook == nil) {
        _userFacebook = [[DGUserSearchFacebookViewController alloc] initWithNibName:@"SearchUserNetworks" bundle:nil];
    }
    if (_userOther == nil) {
        _userOther = [self.storyboard instantiateViewControllerWithIdentifier:@"SearchOther"];
    }

    // self.typeSegmentedControl.selectedSegmentIndex = 1;
    segmentIndex = 1;
    addressBook.selected = YES;

    UIViewController *vc = [self viewControllerForSegmentIndex:segmentIndex];
    self.currentViewController = vc;
    [self addChildViewController:vc];
    [self.contentView addSubview:vc.view];

    // arrow
    CGFloat x = [self getX];
    CGFloat y = buttonRow.frame.origin.y + buttonRow.frame.size.height;
    arrow = [[Arrow alloc] initWithFrame:CGRectMake(x, y, 14, 8)];

    [self.view addSubview:arrow];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Find Friends"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.currentViewController.view.frame = self.contentView.bounds;

    CGFloat y = buttonRow.frame.origin.y + buttonRow.frame.size.height - 2;
    arrow.frame = CGRectMake([self getX], y, 14, 8);
}

- (void)dealloc {
    DebugLog(@"deallocing find friends");
    _currentViewController = nil;
    _userAddressBook = nil;
    _userTwitter = nil;
    _userFacebook = nil;
    _userOther = nil;
}

- (CGFloat)getX {
    CGFloat tabWidth = self.view.frame.size.width / 4;
    return (tabWidth) * (segmentIndex) - (tabWidth / 2 + arrow.frame.size.width / 2);
}

- (IBAction)addressBook:(UIButton *)sender {
    [self deselectButtons];
    sender.selected = YES;
    [self showSectionAtIndex:sender.tag];
}

- (IBAction)twitter:(UIButton *)sender {
    [self deselectButtons];
    sender.selected = YES;
    [self showSectionAtIndex:sender.tag];
}

- (IBAction)facebook:(UIButton *)sender {
    [self deselectButtons];
    sender.selected = YES;
    [self showSectionAtIndex:sender.tag];
}

- (IBAction)other:(UIButton *)sender {
    [self deselectButtons];
    sender.selected = YES;
    [self showSectionAtIndex:sender.tag];
}

- (void)deselectButtons {
    twitter.selected = NO;
    other.selected = NO;
    addressBook.selected = NO;
    facebook.selected = NO;
}

- (void)showSectionAtIndex:(NSInteger)index {
    if (index == segmentIndex) {
        return;
    }
    UIViewController *vc = [self viewControllerForSegmentIndex:index];
    [UIView beginAnimations:@"kSelectionAnimation" context:(__bridge void *)(self.view)];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:kTabSelectionAnimationDuration];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    arrow.frame = CGRectMake([self getX], arrow.frame.origin.y, arrow.frame.size.width, arrow.frame.size.height);
    [UIView commitAnimations];
    DebugLog(@"x %f", [self getX]);

    [self addChildViewController:vc];
    vc.view.frame = self.contentView.bounds;

    [self transitionFromViewController:self.currentViewController toViewController:vc duration:0 options:UIViewAnimationOptionTransitionNone animations:^{
        [self.currentViewController.view removeFromSuperview];
        [self.contentView addSubview:vc.view];
    } completion:^(BOOL finished) {
        [vc didMoveToParentViewController:self];
        [self.currentViewController removeFromParentViewController];
        self.currentViewController = vc;
    }];
    self.navigationItem.title = vc.title;
}

- (UIViewController *)viewControllerForSegmentIndex:(NSInteger)index {
    UIViewController *vc;
    switch (index) {
        case 1:
            vc = self.userAddressBook;
            break;
        case 2:
            vc = self.userTwitter;
            break;
        case 3:
            vc = self.userFacebook;
            break;
        case 4:
            vc = self.userOther;
            break;
    }
    segmentIndex = index;
    return vc;
}

@end
