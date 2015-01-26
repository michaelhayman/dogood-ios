#import "GoodOverviewCell.h"
#import "DGEntityHandler.h"

@implementation GoodOverviewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    characterLimit = 500;
    self.entities = [[NSMutableArray alloc] init];
    self.descriptionText.allowsEditingTextAttributes = NO;
    self.descriptionText.delegate = self;
    self.placeholder.hidden = NO;
}

- (void)initEntityHandler {
    if (self.entityHandler == nil) {
        self.entityHandler = [[DGEntityHandler alloc] initWithTextView:self.descriptionText andEntities:self.entities inController:self.parent andLinkID:[NSNumber numberWithInt:9] reverseScroll:NO tableOffset:100 secondTableOffset:64 characterLimit:characterLimit];
    }
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
    DebugLog(@"dealloc");
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
}

- (void)restoreDefaultImage {
    self.image.image = [self defaultImage];
}

- (UIImage *)defaultImage {
    return [UIImage imageNamed:@"UploadImage"];
}

- (UIImage *)defaultHighlightedImage {
    return [UIImage imageNamed:@"UploadImageTap"];
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

    [self.entityHandler setLimitText];

    BOOL sup = [self.entityHandler check:textField range:(NSRange)range forEntities:self.entities completion:^BOOL(BOOL end, NSMutableArray *newEntities) {
        self.entities = newEntities;
        return end;
    }];
    [self.entityHandler resetTypingAttributes:textField];
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
    /* this crashes the app... and Xcode
    if (self.entityHandler != nil) {
        [self.entityHandler hideEverything];
    }
    */
    [textView resignFirstResponder];
}

#pragma mark - EntityDelegates
- (void)textViewDidChange:(UITextView *)textField {
    if ([textField.text isEqualToString:@""]) {
        self.placeholder.hidden = NO;
    } else {
        self.placeholder.hidden = YES;
    }

    [self.entityHandler watchForEntities:textField];
    [self.entityHandler setLimitText];

    if ([textField.text length] >= characterLimit) {
        // sendButton.enabled = NO;
    } else {
        // sendButton.enabled = YES;
    }
}

@end
