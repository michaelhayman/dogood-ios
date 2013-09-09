@class DGCategory;

@interface CategoryCell : UITableViewCell {
    __weak IBOutlet UILabel *categoryName;
    __weak IBOutlet UIImageView *categoryImage;
}

@property (weak, nonatomic) DGCategory *category;
@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setValues;

@end
