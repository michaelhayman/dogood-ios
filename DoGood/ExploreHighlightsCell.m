#import "ExploreHighlightsCell.h"
#import "HighlightCollectionCell.h"
#import "DGGoodListViewController.h"

#define cellName @"HighlightCollectionCell"

@implementation ExploreHighlightsCell

- (id)initWithController:(UINavigationController *)controller {
    CGRect frame = CGRectMake(0, 0, 320, 100);
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

#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 2;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *reuseIdentifier = cellName;
    HighlightCollectionCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:reuseIdentifier forIndexPath:indexPath];
    if (indexPath.row == popular) {
        [cell setName:@"Popular Now"];
        cell.backgroundColor = COLOUR_BROWN;
    } else {
        [cell setName:@"In\nDemand"];
        cell.backgroundColor = COLOUR_YELLOW;
    }
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    if (indexPath.row == popular) {
        controller.path = @"/goods";
    } else {
        controller.path = @"/goods";
    }
    [self.navigationController pushViewController:controller animated:YES];
}

@end
