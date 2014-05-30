#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    NSString *points = @"point";
    return [NSString stringWithFormat:@"%@ %@", [formatter stringFromNumber:self.cost], [DGAppearance pluralizeString:points basedOnNumber:self.cost]];
}

- (BOOL)userHasSufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.cost intValue];
}

@end
