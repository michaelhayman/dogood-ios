#import "HighlightCollectionCell.h"
#import "DGTag.h"

@implementation HighlightCollectionCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    tagName.font = HIGHLIGHT_COLLECTION_FONT;
    tagName.textColor = [UIColor whiteColor];
}

#pragma mark - Set values when cell becomes visible
- (void)setName:(NSString *)string {
    tagName.text = string;
}

- (void)dealloc {
    DebugLog(@"dealloc");
}

@end
