#import "URLHandler.h"
#import "DGGoodListViewController.h"
#import "DGPostGoodViewController.h"
#import "DGTag.h"

@implementation URLHandler

- (void)openURL:(NSURL *)url andReturn:(openURLBlock)match {
   if ([[url scheme] isEqualToString:@"dogood"]) {
        NSArray *urlComponents = [url pathComponents];
        UINavigationController *nav = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
        DebugLog(@"handle dogood");

        if ([[url host] hasPrefix:@"users"]) {
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * userID = [f numberFromString:urlComponents[1]];
            DebugLog(@"open profile page for %@", userID);
            [DGUser openProfilePage:userID inController:nav];
        }

        if ([[url host] hasPrefix:@"goods"]) {
            if ([urlComponents[1] isEqualToString:@"new"]) {
                BOOL access = NO;
                access = [[DGUser currentUser] authorizeAccess:nav.visibleViewController];
                if (access) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
                    DGPostGoodViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PostGood"];
                    [nav pushViewController:controller animated:YES];
                }
            } else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
                DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
                if ([urlComponents[1] isEqualToString:@"tagged"]) {
                    DGTag *tag = [DGTag new];
                    tag.name = [url pathComponents][2];
                    controller.tag = tag;
                } else {
                    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                    [f setNumberStyle:NSNumberFormatterDecimalStyle];
                    NSNumber * goodID = [f numberFromString:urlComponents[1]];
                    DebugLog(@"open good page for %@", goodID);
                    controller.goodID = goodID;
                }
                [nav pushViewController:controller animated:YES];
            }
        }
        match(YES);
    } else {
        match(NO);
    }
}

@end
