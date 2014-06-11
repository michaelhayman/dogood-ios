#import "NomineeCell.h"
#import "DGNominee.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@implementation NomineeCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)setValues {
    if (self.nominee) {
        self.textLabel.text = self.nominee.full_name;
    } else {
        self.textLabel.text = @"Who did good?";
    }
}

@end
