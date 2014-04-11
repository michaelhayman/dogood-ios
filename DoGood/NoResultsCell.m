#import "NoResultsCell.h"

@implementation NoResultsCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
}

#pragma mark - Set values when cell becomes visible
- (void)setHeading:(NSString *)heading andExplanation:(NSString *)explanation {
    [self setHeading:heading explanation:explanation andImage:nil];
}

- (void)setHeading:(NSString *)heading explanation:(NSString *)explanation andImage:(UIImage *)image {
    if (heading == nil || [heading isEqualToString:@""]) {
        self.headingHeight.constant = 0;
        self.headingSpacer.constant = 0;
    } else {
        self.headingHeight.constant = 40;
        self.headingSpacer.constant = 5;
    }
    self.heading.text = heading;

    if (explanation) {
        self.explanation.text = explanation;

        NSDictionary *attributes = @{ NSFontAttributeName : self.explanation.font };
        NSAttributedString *attrString = [[NSAttributedString alloc] initWithString:self.explanation.text attributes:attributes];
        self.explanationHeight.constant = [DGAppearance calculateHeightForText:attrString andWidth:226];
    }

    if (image) {
        self.imageHeight.constant = 100;
        self.imageSpacer.constant = 10;
        self.image.image = image;
    } else {
        self.imageHeight.constant = 0;
        self.imageSpacer.constant = 0;
    }
}

@end
