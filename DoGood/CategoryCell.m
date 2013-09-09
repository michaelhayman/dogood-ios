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
    // categoryImage setImageWithURL:[NSURL URLWithString:self.category.]
}

@end
