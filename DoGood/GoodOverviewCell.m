#import "GoodOverviewCell.h"
#import "DGEntityHandler.h"

@implementation GoodOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
       // entities
    characterLimit = 500;
    self.entities = [[NSMutableArray alloc] init];
    self.description.allowsEditingTextAttributes = NO;
    self.description.delegate = self;
    self.placeholder.hidden = NO;
    [self setDoneMode:YES];
}

- (void)initEntityHandler {
    self.entityHandler = [[DGEntityHandler alloc] initWithTextView:self.description andEntities:self.entities inController:self.parent withType:@"Good" reverseScroll:NO tableOffset:100 secondTableOffset:64 characterLimit:characterLimit];
}

- (void)prepareForReuse {
    self.entityHandler = nil;
}

- (void)setDoneMode:(BOOL)done {
    if (done) {
        self.placeholder.text = @"Write about a good thing someone did";
    } else {
        self.placeholder.text = @"Persuade people to help do some good";
    }
    self.placeholder.textColor = [UIColor grayColor];
}

- (void)dealloc {
    self.entityHandler = nil;
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
    [_entityHandler setLimitText];

    BOOL sup = [_entityHandler check:textField range:(NSRange)range forEntities:self.entities completion:^BOOL(BOOL end, NSMutableArray *newEntities) {
        self.entities = newEntities;
        return end;
    }];
    [_entityHandler resetTypingAttributes:textField];
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

    [_entityHandler watchForEntities:textField];
    [_entityHandler setLimitText];

    if ([textField.text length] >= characterLimit) {
        // sendButton.enabled = NO;
    } else {
        // sendButton.enabled = YES;
    }
}

@end
