#import "TagCollectionCell.h"
#import "DGTag.h"

@implementation TagCollectionCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
}

#pragma mark - Set values when cell becomes visible
- (void)setValues {
    tagName.text = [self.taggage hashifiedName];
}

@end
