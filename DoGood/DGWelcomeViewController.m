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
    self.navigationController.navigationBarHidden = YES;
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (IBAction)getStarted:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)viewDidLoad {
    [super viewDidLoad];

    tourImages = [NSArray arrayWithObjects:
        [UIImage imageNamed:@"tour_find"],
        [UIImage imageNamed:@"tour_nominate"],
        [UIImage imageNamed:@"tour_do"],
        [UIImage imageNamed:@"tour_reward"],
        nil
    ];

    [self setPageNumber:1];

    [self setupGallery];
    [self setGallerySize];
    [self loadVisiblePages];
}

- (void)setPageNumber:(int)number {
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
        newPageView.tag = page;
        newPageView.image = (tourImages)[page];

        // newPageView.contentMode = UIViewContentModeScaleAspectFill;
        newPageView.contentMode = UIViewContentModeScaleAspectFit;
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