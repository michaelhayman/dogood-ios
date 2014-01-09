#import "DGPostGoodNomineeViewController.h"
#import "DGPostGoodNomineeAddViewController.h"
#import "DGPostGoodNomineeSearchViewController.h"

@interface DGPostGoodNomineeViewController ()
    @property (nonatomic, strong) DGPostGoodNomineeAddViewController *addView;
    @property (nonatomic, strong) DGPostGoodNomineeSearchViewController *searchView;
@end

@implementation DGPostGoodNomineeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupMenuTitle:@"Nominate"];
    if (self.addView == nil) {
        self.addView = [self.storyboard instantiateViewControllerWithIdentifier:@"nomineeAdd"];
        self.addView.delegate = self;
    }
    if (self.searchView == nil) {
        self.searchView = [self.storyboard instantiateViewControllerWithIdentifier:@"nomineeSearch"];
    }
    [self setupNavigationBar];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(nomineeChosen:) name:DGNomineeWasChosen object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(externalNomineeChosen:) name:ExternalNomineeWasChosen object:nil];

    UIViewController *vc = [self viewControllerForSegmentIndex:tabControl.selectedSegmentIndex];
    self.currentViewController = vc;
    [self addChildViewController:vc];
    [self.contentView addSubview:vc.view];
}

- (void)setupNavigationBar {
    tabControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Add", @"Search", nil]];
    [tabControl setImage:[UIImage imageNamed:@"SearchIcon"] forSegmentAtIndex:1];
    [tabControl setImage:[UIImage imageNamed:@"AddIcon"] forSegmentAtIndex:0];
    [tabControl setSelectedSegmentIndex:0];
    [tabControl sizeToFit];
    [tabControl addTarget:self action:@selector(chooseTab:) forControlEvents:UIControlEventValueChanged];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:tabControl];
}

// customize back button
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationController.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:self action:@selector(pop)];
}

// handle 'back' button
- (void)didMoveToParentViewController:(UIViewController *)parent {
    if (![parent isEqual:self.parentViewController]) {
        DebugLog(@"Back pressed");
        [self.addView fillInNomineeFromFields];
        [self.addView nominate:nil];
    }
}

- (void)pop {
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
}

- (void)nomineeChosen:(NSNotification *)notification {
    DGNominee *nominee = [[notification userInfo] valueForKey:@"nominee"];
    [self populateNominee:nominee];
}

- (void)externalNomineeChosen:(NSNotification *)notification {
    DGNominee *nominee = [[notification userInfo] valueForKey:@"nominee"];
    [self.addView fillInFieldsFromNominee:nominee];
    [tabControl setSelectedSegmentIndex:0];
    [self showSectionAtIndex:tabControl.selectedSegmentIndex];
}

- (IBAction)chooseTab:(id)sender {
    DebugLog(@"sup %d", tabControl.selectedSegmentIndex);
    [self showSectionAtIndex:tabControl.selectedSegmentIndex];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)showSectionAtIndex:(NSInteger)index {
    UIViewController *vc = [self viewControllerForSegmentIndex:index];
    [UIView beginAnimations:@"kSelectionAnimation" context:(__bridge void *)(self.view)];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
    [UIView commitAnimations];

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
        case 0:
            vc = self.addView;
            break;
        case 1:
            vc = self.searchView;
            break;
    }
    tabControl.selectedSegmentIndex = index;
    return vc;
}

#pragma mark - other methods
- (void)childViewController:(DGPostGoodNomineeViewController *)viewController didChooseNominee:(DGNominee *)nominee {
    [self populateNominee:nominee];
}

- (void)populateNominee:(DGNominee *)nominee {
    if ([self.delegate respondsToSelector:@selector(childViewController:didChooseNominee:)]) {
        [self.delegate childViewController:self didChooseNominee:nominee];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
