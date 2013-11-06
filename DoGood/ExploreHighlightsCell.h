@interface ExploreHighlightsCell : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {

    __weak IBOutlet UICollectionView *collectionView;
}

@property (nonatomic, weak) IBOutlet UIView *view;
@property (nonatomic, weak) UINavigationController *navigationController;

- (id)initWithController:(UINavigationController *)controller;

typedef enum {
    popular,
    inDemand,
    exploreHighlightRows
} ExploreDoGoodHighlightsRowType;


@end
