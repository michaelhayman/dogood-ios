#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [NSString stringWithFormat:@"%@ points", [formatter stringFromNumber:self.cost]];
}

- (BOOL)userHasSufficientPoints {
    return [[DGUser currentUser].points intValue] >= [self.cost intValue];
}

@end
