#import "DGExploreViewController.h"
#import "DGExploreSearchViewController.h"
#import "DGExploreCategoriesViewController.h"
#import "DGWelcomeViewController.h"

@interface DGExploreViewController ()
    @property (nonatomic, retain) DGExploreSearchViewController *exploreSearch;
    @property (nonatomic, retain) DGExploreCategoriesViewController *exploreCategories;
@end

@implementation DGExploreViewController

@synthesize searchField;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self addMenuButton:@"MenuFromExploreIconTap" withTapButton:@"MenuFromExploreIcon"];
    [self setupMenuTitle:@"Do Good"];

    if (_exploreSearch == nil) {
        _exploreSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreSearch"];
    }
    searchField.delegate = self.exploreSearch;
    _exploreSearch.parent = self;
    _exploreSearch.searchField = searchField;

    if (_exploreCategories == nil) {
        _exploreCategories = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreCategories"];
    }

    [self stylePage];
    [self setupClearButton];
    [self hideCancelButton];

    // setup initial container view
    segmentIndex = 1;
    UIViewController *vc = [self viewControllerForSegmentIndex:segmentIndex];
    _currentViewController = vc;
    [self addChildViewController:vc];
    [_contentView addSubview:vc.view];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self showWelcome];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(showWelcome) name:DGUserDidSignOutNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peopleSelected) name:DGUserDidStartSearchingPeople object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsSelected) name:DGUserDidStartSearchingTags object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidBeginEditing) name:DGSearchTextFieldDidBeginEditing object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidEndEditing) name:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
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
        [self welcomeScreen];
    }
}

- (void)welcomeScreen {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGWelcomeViewController *welcomeViewController = [storyboard instantiateViewControllerWithIdentifier:@"Welcome"];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:welcomeViewController];
    [self presentViewController:navigationController animated:NO completion:nil];
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
