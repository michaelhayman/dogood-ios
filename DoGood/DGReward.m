#import "DGReward.h"

@implementation DGReward

- (NSString *)costText {
    DebugLog(@"number two");
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setGroupingSeparator: [[NSLocale currentLocale] objectForKey:NSLocaleGroupingSeparator]];
    return [formatter stringFromNumber:self.cost];
}

@end
