#import "GoodOverviewCell.h"
#import "DGEntityHandler.h"

@implementation GoodOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
       // entities
    characterLimit = 120;
    self.entities = [[NSMutableArray alloc] init];
    self.description.allowsEditingTextAttributes = NO;
    self.description.delegate = self;
    self.placeholder.hidden = NO;
}

- (void)initEntityHandler {
    entityHandler = [[DGEntityHandler alloc] initWithTextView:self.description andEntities:self.entities inController:self.parent withType:@"Good" reverseScroll:NO tableOffset:100 secondTableOffset:64];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
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
- (BOOL)textView:(UITextView *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    if([string isEqualToString:@"\n"]) {
        [textField resignFirstResponder];
        return NO;
    }

    if (characterLimit == range.location) {
        return NO;
    }

    // int length = textField.text.length - range.length + string.length;
    /*
    if (length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
    */

    // [self setTextViewHeight];
    [entityHandler setLimitText];

    DebugLog(@"check");
    BOOL sup = [entityHandler check:textField range:(NSRange)range forEntities:self.entities completion:^BOOL(BOOL end, NSMutableArray *newEntities) {
        self.entities = newEntities;
        return end;
    }];
    [entityHandler resetTypingAttributes:textField];
    return sup;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    if ([textView.text isEqualToString:@""]) {
        self.placeholder.hidden = NO;
    } else {
        self.placeholder.hidden = YES;
    }
    [textView resignFirstResponder];
}

#pragma mark - EntityDelegates
- (void)textViewDidChange:(UITextView *)textField {
    if ([textField.text isEqualToString:@""]) {
        self.placeholder.hidden = NO;
    } else {
        self.placeholder.hidden = YES;
    }

    [entityHandler watchForEntities:textField];
    [entityHandler setLimitText];

    if ([textField.text length] >= characterLimit) {
        // sendButton.enabled = NO;
    } else {
        // sendButton.enabled = YES;
    }
}

@end
