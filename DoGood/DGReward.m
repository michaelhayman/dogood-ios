#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [NSString stringWithFormat:@"%@ good", [formatter stringFromNumber:self.cost]];
}

@end
