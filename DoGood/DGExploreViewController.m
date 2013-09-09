#import "DGExploreViewController.h"
#import "DGExploreSearchViewController.h"
#import "DGExploreCategoriesViewController.h"

@interface DGExploreViewController ()
    @property (nonatomic, retain) DGExploreSearchViewController *exploreSearch;
    @property (nonatomic, retain) DGExploreCategoriesViewController *exploreCategories;
@end

@implementation DGExploreViewController

@synthesize searchField;

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Explore"];

    self.exploreSearch = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreSearch"];
    searchField.delegate = self.exploreSearch;
    self.exploreSearch.parent = self;
    self.exploreSearch.searchField = searchField;

    self.exploreCategories = [self.storyboard instantiateViewControllerWithIdentifier:@"exploreCategories"];

    [self stylePage];
    [self setupClearButton];

    // setup initial container view
    segmentIndex = 1;
    UIViewController *vc = [self viewControllerForSegmentIndex:segmentIndex];
    self.currentViewController = vc;
    [self addChildViewController:vc];
    [self.contentView addSubview:vc.view];

    // watch notifications
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peopleSelected) name:DGUserDidStartSearchingPeople object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(tagsSelected) name:DGUserDidStartSearchingTags object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidBeginEditing) name:DGSearchTextFieldDidBeginEditing object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(searchFieldDidEndEditing) name:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    // this should be moved elsewhere as we don't want it called constantly
    [self hideCancelButton];
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
    [clearButton setFrame:CGRectMake(0, 0, 20, 20)];
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

// - (void)textFieldDidBeginEditing:(UITextField *)textField {
- (void)searchFieldDidBeginEditing {
    [self showCancelButton];
    [self showSearch];
}

// - (void)textFieldDidEndEditing:(UITextField *)textField {
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
    searchField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchIcon"]];
}

- (void)peopleSelected {
    searchField.placeholder = @"Search for people";
    searchField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchPeopleIcon"]];
}

- (void)tagsSelected {
    searchField.placeholder = @"Search for tags";
    searchField.leftView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"SearchTagsIcon"]];
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
