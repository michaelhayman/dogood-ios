#import "HighlightCollectionCell.h"
#import "DGAppearance.h"

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

- (void)setName:(NSString *)string backgroundColor:(UIColor *)color andIcon:(UIImage *)image {
    [self setName:string];
    self.backgroundColor = color;
    tagName.textColor = MUD;
    icon.image = image;
}

- (void)dealloc {
    DebugLog(@"dealloc");
}

@end
