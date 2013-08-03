#import "DGRewardsListViewController.h"
#import "DGRewardCell.h"

@interface DGRewardsListViewController ()

@end

@implementation DGRewardsListViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    [collectionView registerClass:[DGRewardCell class] forCellWithReuseIdentifier:@"RewardCell"];
    UINib *nib = [UINib nibWithNibName:@"Reward" bundle:nil];
    [collectionView registerNib:nib forCellWithReuseIdentifier:@"RewardCell"];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - UICollectionView methods
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return 11;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)aCollectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    DGRewardCell *cell = [aCollectionView dequeueReusableCellWithReuseIdentifier:@"RewardCell" forIndexPath:indexPath];
    cell.heading.text = @"hey";
    cell.subheading.text = @"There";
    cell.picture.image = [UIImage imageNamed:@"upload-image"];

    return cell;
}

@end
