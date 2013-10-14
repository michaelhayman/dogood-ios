#import "GoodOverviewCell.h"

@implementation GoodOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    [self setDefaultText:self.description];
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

#pragma mark - UITextViewDelegate methods
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

- (void)setDefaultText:(UITextView *)textView {
    textView.text = TEXTVIEW_TEXT;
    textView.textColor = [UIColor lightGrayColor];
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:TEXTVIEW_TEXT]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        [self setDefaultText:textView];
    }
    [textView resignFirstResponder];
}

@end
