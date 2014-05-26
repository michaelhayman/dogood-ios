#import "UserGoodCell.h"

@implementation UserGoodCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)disable {
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
