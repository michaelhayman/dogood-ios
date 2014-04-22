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
    if (![inviteButton isSelected]) {
        [self invite];
    } else {
        [self uninvite];
    }
    DebugLog(@"invite %@", [NSNumber numberWithBool:inviteButton.selected]);
}

- (void)invite {
     [UIAlertView showWithTitle:[NSString stringWithFormat:@"Invite %@", self.nominee.full_name] message:@"Send an invite to Do Good?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Invite"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             DebugLog(@"Cancelled");
         } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Invite"]) {
             self.nominee.invite = inviteButton.selected; NSLog(@"Invite");
             inviteButton.selected = !inviteButton.selected;
         }
    }];
}

- (void)uninvite {
     [UIAlertView showWithTitle:[NSString stringWithFormat:@"Don't invite %@?", self.nominee.full_name] message:@"Remove invitation to Do Good?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[@"Remove"] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             DebugLog(@"Cancelled");
         } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:@"Remove"]) {
             self.nominee.invite = inviteButton.selected; NSLog(@"Invite");
             inviteButton.selected = !inviteButton.selected;
         }
    }];
}

@end
