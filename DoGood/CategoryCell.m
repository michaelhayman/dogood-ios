#import "CategoryCell.h"
#import "DGCategory.h"

@implementation CategoryCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.selectedBackgroundView = [[UIView alloc] initWithFrame:[self contentView].frame];
    self.backgroundView = [[UIView alloc] initWithFrame:[self contentView].frame];
    categoryName.textColor = [UIColor whiteColor];
    categoryName.font = CATEGORY_FONT;
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
    categoryName.text = _category.name;

    if ([_category image]) {
        categoryImage.image = [self.category image];
    } else {
        NSURL *url = [NSURL URLWithString:_category.image_url];
        [categoryImage setImageWithURL:url placeholderImage:[UIImage imageNamed:@"category_empty"]];
    }
    self.backgroundView.backgroundColor = [self.category rgbColour];
}

@end
