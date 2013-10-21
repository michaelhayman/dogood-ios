#import "SignUpOverviewCell.h"

@implementation SignUpOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.userInteractionEnabled = YES;
    self.image.image = [self defaultImage];
    self.image.highlightedImage = [self defaultHighlightedImage];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Set image
- (UIImage *)defaultImage {
    return [UIImage imageNamed:@"upload-image"];
}

- (UIImage *)defaultHighlightedImage {
    return [UIImage imageNamed:@"upload-image-active"];
}

#pragma mark - Change text view
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

@end
