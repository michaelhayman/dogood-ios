@interface ExploreHighlightsCell : UIView <UICollectionViewDataSource, UICollectionViewDelegate> {

    __weak IBOutlet UICollectionView *collectionView;
}

@property (nonatomic, weak) IBOutlet UIView *view;
@property (weak, nonatomic) UINavigationController *navigationController;

- (id)initWithController:(UINavigationController *)controller;

typedef enum {
    popular,
    inDemand,
    exploreHighlightRows
} ExploreDoGoodHighlightsRowType;


@end
