@interface DGExploreViewController : UIViewController <UITextFieldDelegate> {
    __weak IBOutlet UITextField *searchField;
    __weak IBOutlet UIButton *searchButton;
    __weak IBOutlet NSLayoutConstraint *searchFieldWidth;

    NSInteger segmentIndex;
}

@property (nonatomic, retain)    UIViewController *currentViewController;
@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UITextField *searchField;

@end
