#import "UITextFieldCell.h"

@implementation UITextFieldCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)prepareForReuse {
    [super prepareForReuse];
    self.heading.text = @"";
    self.heading.textColor = [UIColor blackColor];
    self.textField.text = @"";
    self.accessoryType = UITableViewCellAccessoryNone;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    // Configure the view for the selected state
}

@end
