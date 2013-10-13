#import "TagCell.h"
#import "DGTag.h"

@implementation TagCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
    tagName.text = [self.taggage hashifiedName];
}

@end
