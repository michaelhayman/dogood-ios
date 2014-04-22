#import "NomineeCell.h"
#import "DGNominee.h"

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
    self.imageView.image = [UIImage imageNamed:@"PostNomineeOff"];
}

- (void)prepareForReuse {
    [super prepareForReuse];
}

- (void)setValues {
    if (self.nominee) {
        self.textLabel.text = self.nominee.full_name;
        self.imageView.image = [UIImage imageNamed:@"PostNomineeOn"];
    } else {
        self.textLabel.text = @"Who did good?";
        self.imageView.image = [UIImage imageNamed:@"PostNomineeOff"];
    }

    UIImage *off;
    UIImage *on;

    if ([self.nominee isPopulated]) {
        off = [UIImage imageNamed:@"InviteOff"];
        on = [UIImage imageNamed:@"InviteGeneric"];
    } else {
        off = nil;
        on = nil;
    }

    inviteButton = [UIButton buttonWithType:UIButtonTypeCustom];
    CGRect frame = CGRectMake(0.0, 0.0, on.size.width, on.size.height);
    inviteButton.frame = frame;
    [inviteButton setBackgroundImage:off forState:UIControlStateNormal];
    [inviteButton setBackgroundImage:on forState:UIControlStateSelected];
    inviteButton.selected = self.nominee.invite;

    [inviteButton addTarget:self action:@selector(changeInvite:)  forControlEvents:UIControlEventTouchUpInside];
    inviteButton.backgroundColor = [UIColor whiteColor];
    self.accessoryView = inviteButton;
}

- (void)changeInvite:(UIButton *)button {
    inviteButton.selected = !inviteButton.selected;
    self.nominee.invite = inviteButton.selected;
    [self setNeedsLayout];
    DebugLog(@"invite %@", [NSNumber numberWithBool:inviteButton.selected]);
}

@end
