#import "URLHandler.h"
#import "DGGoodListViewController.h"
#import "DGPostGoodViewController.h"
#import "DGSignInViewController.h"
#import "DGTag.h"
#import <SVWebViewController/SVWebViewController.h>

@implementation URLHandler

- (void)openURL:(NSURL *)url andReturn:(openURLBlock)match {
    UINavigationController *nav = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;
    if ([[url scheme] isEqualToString:@"dogood"]) {
        NSArray *urlComponents = [url pathComponents];
        DebugLog(@"handle dogood");

        if ([[url host] hasPrefix:@"users"]) {
            if ([urlComponents[1] isEqualToString:@"signIn"]) {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
                DGSignInViewController*controller = [storyboard instantiateViewControllerWithIdentifier:@"SignIn"];
                [nav pushViewController:controller animated:YES];
            } else {
                NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
                [f setNumberStyle:NSNumberFormatterDecimalStyle];
                NSNumber * userID = [f numberFromString:urlComponents[1]];
                DebugLog(@"open profile page for %@", userID);
                [DGUser openProfilePage:userID inController:nav];
            }
        }

        if ([[url host] hasPrefix:@"goods"]) {
            if ([urlComponents[1] isEqualToString:@"new"]) {
                BOOL access = NO;
                access = [[DGUser currentUser] authorizeAccess:nav.visibleViewController];
                if (access) {
                    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
                    DGPostGoodViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"PostGood"];
                    controller.doneGoods = YES;
                    [nav pushViewController:controller animated:YES];
                }
            } else {
                UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
                DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
                if ([urlComponents[1] isEqualToString:@"tagged"]) {
                    DGTag *tag = [DGTag new];
                    NSString * tagName = [NSString stringWithFormat:@"#%@", [url fragment]];
                    tag.name = tagName;
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
    } else if ([[url scheme] isEqualToString:@"http"] || [[url scheme] isEqualToString:@"http"]) {
        DebugLog(@"open url %@", url);
        SVModalWebViewController *webViewController = [[SVModalWebViewController alloc] initWithAddress:[url absoluteString]];
        webViewController.barsTintColor = [UIColor whiteColor];
        [nav.visibleViewController presentViewController:webViewController animated:YES completion:NULL];
    } else {
        match(NO);
    }
}

@end
