#import "CommentCell.h"
#import "DGComment.h"
#import "DGEntity.h"
#import <TTTAttributedLabel.h>
#import "URLHandler.h"
#import "NSString+RangeChecker.h"

@implementation CommentCell

- (void)awakeFromNib {
    [super awakeFromNib];

    UITapGestureRecognizer* avatarGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(showGoodUserProfile)];
    [self.avatar setUserInteractionEnabled:YES];
    [self.avatar addGestureRecognizer:avatarGesture];
    self.commentBody.linkAttributes = [DGAppearance linkAttributes];
    self.commentBody.activeLinkAttributes = [DGAppearance activeLinkAttributes];
    self.commentBody.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

- (void)setValues {
    if ([self.comment.user avatarURL]) {;
        [self.avatar setImageWithURL:[self.comment.user avatarURL]];
    } else {
        self.avatar.image = nil;
    }

    self.timePosted.text = [[self.comment createdAgoInWords] uppercaseString];

    NSDictionary *attributes = @{ NSFontAttributeName : self.commentBody.font };
    NSString *text =[NSString stringWithFormat:@"%@ %@", self.comment.user.full_name, self.comment.comment];
    NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:text attributes:attributes];
    self.commentBody.attributedText = attrString;

    UIFont *font = [UIFont boldSystemFontOfSize:13];
    [CommentCell addUsernameAndLinksToComment:self.comment withText:text andFont:font inLabel:self.commentBody];

    CGFloat height = [DGAppearance calculateHeightForString:self.commentBody.text WithFont:self.commentBody.font andWidth:[DGComment commentBoxWidth]];

    self.commentBody.delegate = self;
    self.commentBodyHeight.constant = height;
    [self layoutIfNeeded];
}

#pragma mark - TTTAttributedLabel delegate methods
- (void)attributedLabel:(TTTAttributedLabel *)label didSelectLinkWithURL:(NSURL *)url {
    URLHandler *handler = [[URLHandler alloc] init];
    [handler openURL:url andReturn:^(BOOL matched) {
        return matched;
    }];
}

#pragma mark - User profile helper
- (void)showGoodUserProfile {
    [DGUser openProfilePage:self.comment.user.userID inController:self.navigationController];
}

+ (void)addUsernameAndLinksToComment:(DGComment *)comment withText:(NSString *)text andFont:(UIFont *)font inLabel:(TTTAttributedLabel*)label {
    [label setText:text afterInheritingLabelAttributesAndConfiguringWithBlock:^NSMutableAttributedString *(NSMutableAttributedString *mutableAttributedString) {
        NSRange stringRange = NSMakeRange(0, [mutableAttributedString length]);

        NSRegularExpression *regexp = [[NSRegularExpression alloc] initWithPattern:[NSString stringWithFormat:@"%@+",comment.user.full_name] options:NSRegularExpressionCaseInsensitive error:nil];

        [regexp enumerateMatchesInString:[mutableAttributedString string] options:0 range:stringRange usingBlock:^(NSTextCheckingResult *result, NSMatchingFlags flags, BOOL *stop) {            
            UIFont *italicSystemFont = font;
            CTFontRef italicFont = CTFontCreateWithName((__bridge CFStringRef)italicSystemFont.fontName, italicSystemFont.pointSize, NULL);
            if (italicFont) {
                [mutableAttributedString removeAttribute:(NSString *)kCTFontAttributeName range:result.range];
                [mutableAttributedString addAttribute:(NSString *)kCTFontAttributeName value:(__bridge id)italicFont range:result.range];
                CFRelease(italicFont);
                
                [mutableAttributedString removeAttribute:(NSString *)kCTForegroundColorAttributeName range:result.range];
                [mutableAttributedString addAttribute:(NSString *)kCTForegroundColorAttributeName value:(__bridge id)[[UIColor grayColor] CGColor] range:result.range];
            }
        }];

        return mutableAttributedString;
    }];

    NSRange r = [text rangeOfString:comment.user.full_name];

    if ([comment.comment containsRange:r]) {
        [label addLinkToURL:[NSURL URLWithString:[NSString stringWithFormat:@"dogood://users/%@", comment.user.userID]] withRange:r];
    }

    for (DGEntity *entity in comment.entities) {
        NSRange commentRange = [entity rangeFromArrayWithOffset:[comment.user.full_name length] + 1];

        if ([text containsRange:commentRange]) {
            NSURL *url = [NSURL URLWithString:entity.link];
            [label addLinkToURL:url withRange:commentRange];
        }
    }
}

@end
