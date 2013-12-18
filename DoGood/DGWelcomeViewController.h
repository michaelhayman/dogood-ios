@class DGGoodListViewController;
@interface DGWelcomeViewController : UIViewController {
    __weak IBOutlet UIButton *getStartedButton;
    NSArray *tourImages;

    __weak IBOutlet UIScrollView *gallery;
    __weak IBOutlet UIPageControl *galleryControl;
}

@property (nonatomic, strong) NSMutableArray *pageViews;
@property (weak, nonatomic) DGGoodListViewController* goodList;

@end
