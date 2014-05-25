#import "UserGoodCell.h"
#import "UIImage+Grayscale.h"

@implementation UserGoodCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)disable {
    self.icon.image = [self.icon.image convertToGrayscale];
    self.sectionName.textColor = GRAYED_OUT;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    self.userInteractionEnabled = NO;
}

- (void)enable {
    self.sectionName.textColor = MUD;
    self.selectionStyle = UITableViewCellSelectionStyleGray;
    self.userInteractionEnabled = YES;
}


- (void)dealloc {
}

@end
