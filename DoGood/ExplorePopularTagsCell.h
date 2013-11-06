@interface ExplorePopularTagsCell : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
    __weak IBOutlet UICollectionView *collectionView;
    NSArray *tags;
}

@property (nonatomic, weak) IBOutlet UIView *view;
@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithController:(UINavigationController *)controller;

@end
