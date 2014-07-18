#import "ExplorePopularTagsCell.h"
#import "TagCollectionCell.h"
#import "DGGoodListViewController.h"
#import <ProgressHUD/ProgressHUD.h>

#define cellName @"TagCollectionCell"

@implementation ExplorePopularTagsCell

- (id)initWithController:(UINavigationController *)controller {
    CGRect frame = CGRectMake(0, 0, 320, 218);
    self = [super initWithFrame:frame];

    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"ExplorePopularTagsCell" owner:self options:nil];
        [self addSubview:self.view];
        self.navigationController = controller;

        [collectionView registerClass:[TagCollectionCell class] forCellWithReuseIdentifier:cellName];
        UINib *nib = [UINib nibWithNibName:cellName bundle:nil];
        [collectionView registerNib:nib forCellWithReuseIdentifier:cellName];

        popularTagsHeading.hidden = YES;
        [self getTags];
    }
    return self;
}

- (void)getTags {
    NSString *resourcePath = @"/tags/popular";

    [[RKObjectManager sharedManager] getObjectsAtPath:resourcePath parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        tags = mappingResult.array;
        if ([tags count] > 0) {
            popularTagsHeading.hidden = NO;
        }
        [collectionView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [ProgressHUD showError:[error localizedDescription]];
        DebugLog(@"Hit error: %@", error);
    }];
}

#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return [tags count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    TagCollectionCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:cellName forIndexPath:indexPath];
    cell.taggage = [tags objectAtIndex:indexPath.row];
    cell.contentView.layer.borderWidth = 1.0;
    cell.contentView.layer.borderColor = [[UIColor whiteColor] CGColor];
    [cell setValues];
    cell.backgroundColor = COLOUR_OFF_WHITE;
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    DGTag * tag = [tags objectAtIndex:indexPath.row];
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
    controller.tag = tag;
    [self.navigationController pushViewController:controller animated:YES];
}

@end
