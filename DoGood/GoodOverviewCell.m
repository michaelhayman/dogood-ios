#import "GoodOverviewCell.h"

@implementation GoodOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.description.backgroundColor = [UIColor clearColor];
    self.image.contentMode = UIViewContentModeScaleAspectFit;
    self.image.userInteractionEnabled = YES;
    self.image.image = [self defaultImage];
    self.image.highlightedImage = [self defaultHighlightedImage];
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (UIImage *)defaultImage {
    return [UIImage imageNamed:@"upload-image"];
}

- (UIImage *)defaultHighlightedImage {
    return [UIImage imageNamed:@"upload-image-active"];
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

@end
