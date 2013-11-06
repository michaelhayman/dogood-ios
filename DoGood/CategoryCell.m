#import "CategoryCell.h"
#import "DGCategory.h"

@implementation CategoryCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
    categoryName.text = _category.name;

    if ([_category image]) {
        categoryImage.image = [self.category image];
    } else {
        NSURL *url = [NSURL URLWithString:_category.image_url];
        [categoryImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"category_empty.png"]];
    }
}

@end
