#import "NominateExplanationCell.h"
#import "DGPostGoodNomineeSearchViewController.h"

@implementation NominateExplanationCell

#pragma mark - Initial setup
- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    [DGAppearance styleActionButton:self.addButton];
    [self.addButton addTarget:self action:@selector(addNominee:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Set values when cell becomes visible
- (IBAction)addNominee:(id)sender {
    [self.parent chooseAdd];
}

@end
