#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [NSString stringWithFormat:@"%@ pts", [formatter stringFromNumber:self.cost]];
}

@end
