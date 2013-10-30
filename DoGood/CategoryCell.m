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
    categoryName.text = self.category.name;

    if ([self.category image]) {
        categoryImage.image = [self.category image];
    } else {
        [categoryImage setImageWithURL:[NSURL URLWithString:self.category.image_url] placeholderImage:[UIImage imageNamed:@"category_empty.png"]];
    }
}

@end
