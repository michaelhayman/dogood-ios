#import "DGExploreViewController.h"
#import "DGExploreSearchViewController.h"
#import "DGExploreCategoriesViewController.h"
#import "DGWelcomeViewController.h"
#import "URLHandler.h"
#import "DGUserProfileViewController.h"

@interface DGExploreViewController ()
    @property (nonatomic, retain) DGExploreSearchViewController *exploreSearch;
    @property (nonatomic, retain) DGExploreCategoriesViewController *exploreCategories;
@end

@implementation DGExploreViewController

@synthesize searchField;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuImage:[UIImage imageNamed:@"DoGoodLogo"]];

    if (self.exploreSearch == nil) {
        self.exploreSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreSearch"];
    }
    searchField.delegate = self.exploreSearch;
    self.exploreSearch.parent = self;
    self.exploreSearch.searchField = searchField;

    if (self.exploreCategories == nil) {
        self.exploreCategories = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreCategories"];
    }

    [self stylePage];
    [self setupClearButton];
    [self hideCancelButton];

    // setup initial container view
    segmentIndex = 1;
    UIViewController *vc = [self viewControllerForSegmentIndex:segmentIndex];
    self.currentViewController = vc;
    [self addChildViewController:vc];
    [self.contentView addSubview:vc.view];
    self.navigationItem.rightBarButtonItem = [DGAppearance postBarButtonItemFor:self];

    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_menu"] style:UIBarButtonItemStylePlain target:self action:@selector(showProfile)];
}

- (void)showProfile {
    if (userProfileController == nil) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
        userProfileController = [storyboard instantiateViewControllerWithIdentifier:@"UserProfile"];
    }
    userProfileController.userID = [DGUser currentUser].userID;
    userProfileController.fromMenu = YES;

    [self.navigationController pushViewController:userProfileController animated:YES];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showWelcome];
}

- (IBAction)postGood:(id)sender {
    URLHandler *handler = [[URLHandler alloc] init];
    NSURL *url = [NSURL URLWithString:@"dogood://goods/new"];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Home"];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(welcomeScreen) name:DGTourWasRequested object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticate) name:DGUserDidFailSilentAuthenticationNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peopleSelected) name:DGUserDidStartSearchingPeople object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsSelected) name:DGUserDidStartSearchingTags object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidBeginEditing) name:DGSearchTextFieldDidBeginEditing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidEndEditing) name:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGTourWasRequested object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidFailSilentAuthenticationNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidStartSearchingPeople object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidStartSearchingTags object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGSearchTextFieldDidBeginEditing object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)authenticate {
    [[DGUser currentUser] authorizeAccess:self];
}

- (void)stylePage {
    [searchField setLeftViewMode:UITextFieldViewModeAlways];
    [self nothingSelected];
}

#pragma mark - Search Field
- (void)setupClearButton {
    UIButton *clearButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [clearButton setImage:[UIImage imageNamed:@"SearchCancel"] forState:UIControlStateNormal];
    [clearButton setImage:[UIImage imageNamed:@"SearchCancelTap"] forState:UIControlStateHighlighted];
    [clearButton setFrame:CGRectMake(0, 0, 30, 20)];
    clearButton.imageView.contentMode = UIViewContentModeLeft;
    [clearButton addTarget:self action:@selector(clearTextField:) forControlEvents:UIControlEventTouchUpInside];

    [searchField setRightViewMode:UITextFieldViewModeAlways];
    [searchField setRightView:clearButton];
    searchField.rightView.hidden = YES;
}

- (void)clearTextField:(id)sender {
    searchField.text = @"";
}

- (IBAction)cancel:(id)sender {
    searchField.text = @"";
    searchField.rightView.hidden = YES;
    [self hideCancelButton];
    [self nothingSelected];
    [self showCategories];
}

- (void)showWelcome {
    if ([DGUser showWelcomeMessage]) {
        [self presentWelcomeScreen:NO];
    }
}

- (void)welcomeScreen {
    [self presentWelcomeScreen:YES];
}

- (void)presentWelcomeScreen:(BOOL)animated {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    if (iPad) {
        navigationController.modalPresentationStyle = UIModalPresentationFormSheet;
        navigationController.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    }
    [self presentViewController:navigationController animated:animated completion:nil];
    if (iPad) {
        navigationController.view.superview.bounds = CGRectMake(0, 0, 320, 480);
    }
}

- (void)showCancelButton {
    searchButton.hidden = NO;
    searchFieldWidth.constant = 237;

    [self animateSearchField];
}

- (void)hideCancelButton {
    [searchField resignFirstResponder];
    searchFieldWidth.constant = 300;
    searchButton.hidden = YES;

    [self animateSearchField];
}

- (void)animateSearchField {
    [searchField setNeedsUpdateConstraints];
    [searchButton setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.25f animations:^{
        [searchField layoutIfNeeded];
        [searchButton layoutIfNeeded];
    }];
}

- (void)showSearch {
    [self showSectionAtIndex:2];
}

- (void)showCategories {
    [self showSectionAtIndex:1];
}

- (void)searchFieldDidBeginEditing {
    [self showCancelButton];
    [self showSearch];
}

- (void)searchFieldDidEndEditing {
    DebugLog(@"ending");
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    self.currentViewController.view.frame = self.contentView.bounds;
}

#pragma mark - Search Icons
- (void)nothingSelected {
    searchField.placeholder = @"Search for people or tags";
      
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 16)];
    image.image = [UIImage imageNamed:@"SearchIcon"];
    image.contentMode = UIViewContentModeRight;
    searchField.leftView = image;
}

- (void)peopleSelected {
    searchField.placeholder = @"Search for people";
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 16)];
    image.image = [UIImage imageNamed:@"SearchPeopleIcon"];
    image.contentMode = UIViewContentModeRight;
    searchField.leftView = image;
}

- (void)tagsSelected {
    searchField.placeholder = @"Search for tags";
    UIImageView* image = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 20, 16)];
    image.image = [UIImage imageNamed:@"SearchTagsIcon"];
    image.contentMode = UIViewContentModeRight;
    searchField.leftView = image;
}

#pragma mark - Swap views
- (void)showSectionAtIndex:(NSInteger)index {
    if (index == segmentIndex) {
        return;
    }
    UIViewController *vc = [self viewControllerForSegmentIndex:index];

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
            vc = self.exploreCategories;
            break;
        case 2:
            vc = self.exploreSearch;
            break;
    }
    segmentIndex = index;
    return vc;
}

@end
