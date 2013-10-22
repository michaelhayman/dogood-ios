#import "Kiwi.h"
#import "DGUser.h"
#import "constants.h"

SPEC_BEGIN(MathSpec)

describe(@"Math", ^{
    it(@"is pretty cool", ^{
        NSUInteger a = 16;
        NSUInteger b = 26;
        [[theValue(a + b) should] equal:theValue(42)];
    });
});

describe(@"the user", ^{
    beforeAll(^{
        // NSMutableDictionary *testDefaults = @{}.mutableCopy;
        // [[NSUserDefaults standardUserDefaults] stub:@selector(synchronize)];
        // [NSUserDefaults stub:@selector(standardUserDefaults) andReturn:testDefaults];
    });

    it(@"should have all their credentials wiped on sign out", ^{
        // [[DGUser currentUser] signOutWithMessage:NO];
        // [[NSUserDefaults standardUserDefaults] setObject:@"hi" forKey:kDGUserCurrentUserIDDefaultsKey];
        // [[[[NSUserDefaults standardUserDefaults] objectForKey:kDGUserCurrentUserIDDefaultsKey] should] equal:@"hi"];
        // [NSUserDefaults.standardUserDefaults setObject:@"hi" forKey:@"hi"];
        // [NSUserDefaults.standardUserDefaults setObject:@"hi" forKey:@"hi"];
        // [[ABConfiguration.appVersion should] equal:FOO];
    });
});

SPEC_END
