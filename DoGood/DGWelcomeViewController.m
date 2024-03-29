#import "DGWelcomeViewController.h"
#import "DGGoodListViewController.h"
#import "DGSignInViewController.h"
#import "DGSignUpViewController.h"

@interface DGWelcomeViewController ()
@end

@implementation DGWelcomeViewController

#pragma mark - View lifecycle
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Welcome Tour"];
    if (!iPad) {
        [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (IBAction)getStarted:(id)sender {
    [DGUser welcomeMessageShown];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    tourImages = [NSArray arrayWithObjects:
        [UIImage imageNamed:@"dg_tour1_iphone5"],
        [UIImage imageNamed:@"dg_tour2_iphone5"],
        [UIImage imageNamed:@"dg_tour3_iphone5"],
        nil
    ];

    [self setPageNumber:1];

    [self setupGallery];
    [self setGallerySize];
    [self loadVisiblePages];
}

- (void)setPageNumber:(NSInteger)number {
    if ([tourImages count] > 0) {
        galleryControl.currentPage = number;
    } else {
        galleryControl.currentPage = 0;
    }
}

#pragma mark - UIScrollViewDelegate methods
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    [self loadVisiblePages];
}

#pragma mark - Gallery
- (void)setupGallery {
    NSInteger pageCount = tourImages.count;
 
    // 2
    galleryControl.currentPage = 0;
    galleryControl.numberOfPages = pageCount;
 
    // 3
    self.pageViews = [[NSMutableArray alloc] init];
    for (NSInteger i = 0; i < pageCount; ++i) {
        [self.pageViews addObject:[NSNull null]];
    }
}

- (void)setGallerySize {
    CGSize pagesScrollViewSize = gallery.frame.size;
    gallery.contentSize = CGSizeMake(pagesScrollViewSize.width * tourImages.count, pagesScrollViewSize.height);
}

- (void)loadVisiblePages {
    // First, determine which page is currently visible
    CGFloat pageWidth = gallery.frame.size.width;
    NSInteger page = (NSInteger)floor((gallery.contentOffset.x * 2.0f + pageWidth) / (pageWidth * 2.0f));
    
    // Update the page control
    galleryControl.currentPage = page;
    [self setPageNumber:page];
    
    // Work out which pages you want to load
    NSInteger firstPage = page - 1;
    NSInteger lastPage = page + 1;
    
    // Purge anything before the first page
    for (NSInteger i=0; i<firstPage; i++) {
        [self purgePage:i];
    }
    
	// Load pages in our range
    for (NSInteger i=firstPage; i<=lastPage; i++) {
        [self loadPage:i];
    }
    
	// Purge anything after the last page
    for (NSInteger i=lastPage+1; i < tourImages.count; i++) {
        [self purgePage:i];
    }
}

#pragma mark - Helpers
- (void)loadPage:(NSInteger)page {
    if (page < 0 || page >= tourImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // 1
    UIView *pageView = (self.pageViews)[page];
    if ((NSNull*)pageView == [NSNull null]) {
        // 2
        CGRect frame = gallery.bounds;
        frame.origin.x = frame.size.width * page;
        frame.origin.y = 0.0f;
        
        // 3
        UIImageView *newPageView = [[UIImageView alloc] init];
        newPageView.contentMode = UIViewContentModeTop;
        newPageView.tag = page;
        newPageView.image = (tourImages)[page];

        newPageView.frame = frame;
        [gallery addSubview:newPageView];

        // 4
        (self.pageViews)[page] = newPageView;
    }
}

- (void)purgePage:(NSInteger)page {
    if (page < 0 || page >= tourImages.count) {
        // If it's outside the range of what you have to display, then do nothing
        return;
    }
    
    // Remove a page from the scroll view and reset the container array
    UIView *pageView = (self.pageViews)[page];
    if ((NSNull*)pageView != [NSNull null]) {
        [pageView removeFromSuperview];
        (self.pageViews)[page] = [NSNull null];
    }
}

@end