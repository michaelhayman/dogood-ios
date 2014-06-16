#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    if ([self.cost isEqualToNumber:[NSNumber numberWithInt:0]]) {
        return @"";
    }

    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    NSString *points = @"point";
    return [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:self.cost], [DGAppearance pluralizeString:points basedOnNumber:self.cost]];
}

- (BOOL)userHasSufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.cost intValue];
}

- (id)initWithEmptyReward {
    self = [super init];
    if (self) {
        self.teaserImage = [UIImage imageNamed:@"NoRewards"];
        self.title = @"No rewards available";
        self.subtitle = @"Do more good!";
        self.cost = [NSNumber numberWithInt:0];
    }
    return self;
}

@end
