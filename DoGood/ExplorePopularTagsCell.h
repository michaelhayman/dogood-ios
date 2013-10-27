@interface ExplorePopularTagsCell : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
    __weak IBOutlet UICollectionView *collectionView;
    NSArray *tags;
}

@property (nonatomic, retain) IBOutlet UIView *view;
@property (weak, nonatomic) UINavigationController *navigationController;
- (id)initWithController:(UINavigationController *)controller;

@end
