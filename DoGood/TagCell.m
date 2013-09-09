#import "TagCell.h"

@implementation TagCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
}

@end
