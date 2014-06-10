@interface ExplorePopularTagsCell : UIView <UICollectionViewDelegate, UICollectionViewDataSource> {
    __weak IBOutlet UICollectionView *collectionView;
    __weak IBOutlet UILabel *popularTagsHeading;
    NSArray *tags;
}

@property (nonatomic, weak) IBOutlet UIView *view;
@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithController:(UINavigationController *)controller;
- (void)getTags;

@end
