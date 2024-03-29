#import "ExploreHighlightsCell.h"
#import "HighlightCollectionCell.h"
#import "DGGoodListViewController.h"
#import "DGGoodListNearbyViewController.h"
#import "DGRewardsListViewController.h"

#define cellName @"HighlightCollectionCell"

@implementation ExploreHighlightsCell

- (id)initWithController:(UINavigationController *)controller {
    CGRect frame = CGRectMake(0, 0, 213, 95);
    self = [super initWithFrame:frame];

    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ExploreHighlightsCell" owner:self options:nil];
        [self addSubview:self.view];
        self.navigationController = controller;
        [collectionView registerClass:[HighlightCollectionCell class] forCellWithReuseIdentifier:cellName];
        UINib *nib = [UINib nibWithNibName:cellName bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:cellName];

        collectionView.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc {
    DebugLog(@"dealloc called");
}

#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return exploreHighlightRows;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = cellName;
    HighlightCollectionCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    NSString *name;
    UIColor *color;
    if (indexPath.row == popular) {
        name = @"Popular";
        color = PINEAPPLE;
    } else {
        name = @"Nearby";
        color = SKY;
    }
    [cell setName:name backgroundColor:color andIcon:[UIImage imageNamed:name]];
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    if (indexPath.row == popular) {
        DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
        controller.path = @"/goods/popular";
        controller.titleForPath = @"Popular";
        controller.color = PINEAPPLE;
        [self.navigationController pushViewController:controller animated:YES];
    } else {
        DGGoodListNearbyViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodListNearby"];
        [self.navigationController pushViewController:controller animated:YES];
    }
}

@end
