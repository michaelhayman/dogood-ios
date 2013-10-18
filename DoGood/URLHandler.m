#import "URLHandler.h"
#import "DGGoodListViewController.h"
#import "DGTag.h"

@implementation URLHandler

- (void)openURL:(NSURL *)url andReturn:(openURLBlock)match {
   if ([[url scheme] isEqualToString:@"dogood"]) {
        DebugLog(@"handle dogood");
        if ([[url host] hasPrefix:@"users"]) {
            NSArray *urlComponents = [url pathComponents];
            NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
            [f setNumberStyle:NSNumberFormatterDecimalStyle];
            NSNumber * userID = [f numberFromString:urlComponents[1]];
            DebugLog(@"open profile page for %@", userID);
            [DGUser openProfilePage:userID inController:(UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController];
        }
        if ([[url host] hasPrefix:@"goods"]) {
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
            DGGoodListViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];
            NSArray *urlComponents = [url pathComponents];
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
            [(UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController pushViewController:controller animated:YES];
        }
       match(YES);
    } else {
        match(NO);
    }
}

@end
