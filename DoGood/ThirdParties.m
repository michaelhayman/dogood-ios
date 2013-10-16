#import "ThirdParties.h"
// Foursquare
// #import "Foursquare-API-v2/Foursquare2.h"

// iOS Social
#import <Accounts/Accounts.h>
#import <Social/Social.h>

// Facebook
#import "FBRequestConnection.h"
#import "FBSession.h"
// #import <FacebookSDK/Facebook.h>

@implementation ThirdParties

#pragma mark - Foursquare
/*
+ (void)setupFoursquare {
    [Foursquare2 setupFoursquareWithKey:@"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII" secret:@"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP" callbackURL:@"app://dogood"];
}
*/

/*
 + (ACAccount *)chooseAccountForAccountStore:(ACAccountStore *)accountStore ofType:(ACAccountType *)type {
     NSArray *twitterAccounts =
     [accountStore accountsWithAccountType:type];
     [[accountStore accountsWithAccountType:type] lastObject];

     // use the last account for now
     return  [twitterAccounts lastObject];
}
NSNumber *tempUserID = [self getTwitterIDFromAccount:[[accountStore accountsWithAccountType:type] lastObject]];
[self saveTwitterID:tempUserID];
*/

#pragma mark - Twitter
+ (void)checkTwitterAccess:(bool)prompt {
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    ACAccountType *accountType = [accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];

    [accountStore requestAccessToAccountsWithType:accountType options:nil completion:^(BOOL granted, NSError *error) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (granted == YES) {
            DebugLog(@"granted");
            NSNumber *tempUserID = [self getTwitterIDFromAccount:[[accountStore accountsWithAccountType:accountType] lastObject]];
            if (tempUserID) {
                DebugLog(@"tweeter");
                [self saveTwitterID:tempUserID];
                [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"connected"];
            } else {
                DebugLog(@"no tweeter");
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"connected"];
                if (prompt) {
                     [self performSelectorOnMainThread:@selector(noTwitterAccountMessage) withObject:self waitUntilDone:NO];
                }
            }
        } else {
            [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"connected"];
            if ([error code] == ACErrorAccountNotFound) {
                DebugLog(@"no accounts defined");
                if (prompt) {
                     [self performSelectorOnMainThread:@selector(noTwitterAccountMessage) withObject:self waitUntilDone:NO];
                }
             }
             else if (error == nil) {
                if (prompt) {
                    [self performSelectorOnMainThread:@selector(appNotAllowedToAccessTwitterMessage) withObject:self waitUntilDone:NO];
                }
                DebugLog(@"no error");
             }
             else {
                 DebugLog(@"error %d", [error code]);
             }
        }
        DebugLog(@"granted? %d", granted);
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCheckIfTwitterIsConnected object:nil userInfo:dictionary];
     }];
}

+ (void)noTwitterAccountMessage {
    UIAlertView *alertViewTwitter = [[UIAlertView alloc] initWithTitle:@"No Twitter Accounts" message:@"There are no Twitter accounts configured. You can add or create a Twitter account in Settings." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [alertViewTwitter show];
}

+ (void)appNotAllowedToAccessTwitterMessage {
    UIAlertView *alertViewTwitter = [[UIAlertView alloc] initWithTitle:@"Enable Do Good" message:@"Go to Settings > Privacy and enable Twitter access for Do Good." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];

    [alertViewTwitter show];
}

+ (BOOL)userHasAccessToTwitter {
    return [SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter];
}

+ (void)postToTwitter:(NSString *)status {
    DebugLog(@"post to twitter in third parties");
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {

        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             DebugLog(@"requesting access");
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];
                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/update.json"];
                 NSDictionary *params = @{@"status" : status};
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodPOST
                                              URL:url
                                       parameters:params];

                 //  Attach an account to the request
                 [request setAccount:[twitterAccounts lastObject]];

                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             NSError *jsonError;
                             NSDictionary *statusData =
                             [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingAllowFragments error:&jsonError];

                             if (statusData) {
                                 DebugLog(@"Status Response: %@\n", statusData);
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 DebugLog(@"JSON Error: %@", [jsonError localizedDescription]);
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             DebugLog(@"The response status code is %d", urlResponse.statusCode);
                         }
                     } else {
                         DebugLog(@"no response data");
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 DebugLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        DebugLog(@"user doesn't have access");
    }
}

+ (void)getTwitterFriendsOnDoGood {
    DebugLog(@"post to twitter in third parties");
    ACAccountStore *accountStore = [[ACAccountStore alloc] init];
    //  Step 0: Check that the user has local Twitter accounts
    if ([self userHasAccessToTwitter]) {

        //  Step 1:  Obtain access to the user's Twitter accounts
        ACAccountType *twitterAccountType = [accountStore
                                             accountTypeWithAccountTypeIdentifier:
                                             ACAccountTypeIdentifierTwitter];
        [accountStore
         requestAccessToAccountsWithType:twitterAccountType
         options:NULL
         completion:^(BOOL granted, NSError *error) {
             DebugLog(@"requesting access");
             if (granted) {
                 //  Step 2:  Create a request
                 NSArray *twitterAccounts =
                 [accountStore accountsWithAccountType:twitterAccountType];

                 // use the last account for now
                 ACAccount * account = [twitterAccounts lastObject];

                 NSString *tempUserID = [[self getTwitterIDFromAccount:account] stringValue];
                 // [self saveTwitterID:tempUserID];

                 /*
                 NSDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:
                                           [account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]]];
                 NSString *tempUserID = [[tempDict objectForKey:@"properties"] objectForKey:@"user_id"];
                 DebugLog(@"temp user id %@", tempUserID);
                 */

                 NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/friends/ids.json"];
                 // NSDictionary *params = @{@"screen_name" : [account username],
                 NSDictionary *params = @{@"user_id" : tempUserID//,
                                          // @"include_user_entities": @"false",
                                          //@"skip_status": @"true"
                                          };
                 SLRequest *request =
                 [SLRequest requestForServiceType:SLServiceTypeTwitter
                                    requestMethod:SLRequestMethodGET
                                              URL:url
                                       parameters:params];

                 //  Attach an account to the request
                 [request setAccount:account];

                 //  Step 3:  Execute the request
                 [request performRequestWithHandler:^(NSData *responseData,
                                                      NSHTTPURLResponse *urlResponse,
                                                      NSError *error) {
                     if (responseData) {
                         if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                             NSError *jsonError;
                             NSDictionary *statusData =
                             [NSJSONSerialization
                              JSONObjectWithData:responseData
                              options:NSJSONReadingAllowFragments error:&jsonError];

                             if (statusData) {
                                 DebugLog(@"Status Response: %@\n", statusData);
                                 [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFindFriendsOnTwitter object:nil userInfo:statusData] ;
                                 // NSArray *users = statusData[@"ids"];
                                 // DebugLog(@"users %@", users);
                             }
                             else {
                                 // Our JSON deserialization went awry
                                 DebugLog(@"JSON Error: %@", [jsonError localizedDescription]);
                             }
                         }
                         else {
                             // The server did not respond successfully... were we rate-limited?
                             DebugLog(@"The response status code is %d", urlResponse.statusCode);
                             [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailFindFriendsOnTwitter object:nil] ;
                         }
                     } else {
                         DebugLog(@"no response data");
                     }
                 }];
             }
             else {
                 // Access was not granted, or an error occurred
                 DebugLog(@"%@", [error localizedDescription]);
             }
         }];
    } else {
        DebugLog(@"user doesn't have access");
    }
}

+ (NSNumber *)getTwitterIDFromAccount:(ACAccount *)account {
    NSDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary:
                               [account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]]];
    NSString *tempUserID = [[tempDict objectForKey:@"properties"] objectForKey:@"user_id"];
    DebugLog(@"temp twitter id %@", tempUserID);
    NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
    [f setNumberStyle:NSNumberFormatterDecimalStyle];
    return [f numberFromString:tempUserID];
}

+ (void)saveTwitterID:(NSNumber *)twitterID {
    [[DGUser currentUser] saveSocialID:twitterID withType:@"twitter"];
    /*
        NSDictionary *userData = (NSDictionary *)data;
        DebugLog(@"data about current user %@", userData);

        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * facebookID = [f numberFromString:userData[@"id"]];
        DebugLog(@"fb id %@", facebookID);

        [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
    */
}

#pragma mark - Facebook
+ (void)postToFacebook:(NSString *)status andImage:(UIImage *)image {
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"message"] = @"I did some good!";
    params[@"link"] = @"http://www.dogoodapp.com/";
    params[@"name"] = @"Do Good, get a high score and earn rewards.";
    params[@"caption"] = status;

    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             DebugLog(@"%@", [NSString stringWithFormat: @"Posted action, id: %@", result[@"id"]]);
         } else {
             DebugLog(@"error! %@", [error description]);
         }
     }];
}

+ (void)facebookHandleDidBecomeActive {
    [FBSession.activeSession handleDidBecomeActive];
}

+ (bool)facebookHandleOpenURL:(NSURL *)url {
    return [FBSession.activeSession handleOpenURL:url];
}

+ (void)checkFacebookAccess {
    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"connected"];
        DebugLog(@"connected");
    } else {
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"connected"];
        DebugLog(@"not connected");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCheckIfFacebookIsConnected object:nil userInfo:dictionary];
}

+ (void)checkFacebookAccessForPosting {
    // See if the app has a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        DebugLog(@"authenticated, check up on permissions");
        [self checkPermissions];
    } else {
        DebugLog(@"not authenticated, display login");
        [self openSession];
    }
}

+ (void)checkFacebookAccessForFriends {
    // See if the app has a valid token for the current state.
    if (FBSession.activeSession.state == FBSessionStateCreatedTokenLoaded) {
        DebugLog(@"authenticated, dont do any more");
    } else {
        DebugLog(@"not authenticated, display login");
        [self openSession];
    }
}

+ (void)requestPermissions {
    DebugLog(@"requesting permissions");
    [FBSession.activeSession requestNewPublishPermissions:@[@"publish_actions"]
                                          defaultAudience:FBSessionDefaultAudienceFriends
                                        completionHandler:^(FBSession *session,
                                                            NSError *error) {
        DebugLog(@"callback from requesting permissions");
        /**
         * There is a bug in Facebook's API where no response is given,
         * so we need to recheck permissions ourselves.
         */
        [self checkFacebookPublishPermissionWithBlock:^(BOOL canShare, NSError *error) {
            NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
            if (canShare) {
                DebugLog(@"has permission");
                [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"permission"];
            } else {
                DebugLog(@"user denied permissions!");
                [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"permission"];
            }
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCheckIfFacebookIsConnectedAndHasPermissions object:nil userInfo:dictionary];
        }];
    }];
}

+ (void)checkPermissions {
    DebugLog(@"check permissions");
    [self checkFacebookPublishPermissionWithBlock:^(BOOL canShare, NSError *error) {
        NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
        if (canShare) {
            DebugLog(@"has permission");
            [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"permission"];
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCheckIfFacebookIsConnectedAndHasPermissions object:nil userInfo:dictionary];
        } else {
            DebugLog(@"prompt for permissions");
            [self requestPermissions];
        }
    }];
}

+ (void)getFacebookFriendsOnDoGood {
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    [FBRequestConnection startForMyFriendsWithCompletionHandler:^(FBRequestConnection *connection, id data, NSError *error) {
        if (error) {
            DebugLog(@"Error requesting /me/friends %@", error);
            return;
        }
        DebugLog(@"data %@", data);

        NSArray* friends = (NSArray*)[data data];
        DebugLog(@"You have %d friends", [friends count]);
        NSDictionary *friendsData = [NSDictionary dictionaryWithObject:NSNullIfNil(friends) forKey:@"facebook_ids"];
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFindFriendsOnFacebook object:nil userInfo:friendsData];
    }];
}

+ (void)checkFacebookPublishPermissionWithBlock:(void (^)(BOOL canShare, NSError *error))completionBlock {
    NSString *permissionsString = @"publish_actions";
    DebugLog(@"fb session %u", FBSession.activeSession.state);
    DebugLog(@"fb session open %d", FBSession.activeSession.isOpen);
    [FBSession openActiveSessionWithAllowLoginUI:NO];
    [FBRequestConnection startWithGraphPath:@"/me/permissions" completionHandler:^(FBRequestConnection *connection, id result, NSError *error) {
        if (!error) {
            DebugLog(@"no error %@", result);
            NSDictionary *data = [[result objectForKey:@"data"] objectAtIndex:0];
            DebugLog(@"data %@", data);
            BOOL canSharePost;

            if ([[data objectForKey:permissionsString] integerValue] == NSNotFound ||
                [[data objectForKey:permissionsString]integerValue] == 0) {
                canSharePost = NO;
                if (completionBlock){
                    completionBlock(canSharePost, error);
                }
            } else {
                canSharePost = YES;
                if (completionBlock){
                    completionBlock(canSharePost,error);
                }
            }
        } else {
            DebugLog(@"error %@", [error description]);
        }
    }];
}

+ (void)sessionStateChanged:(FBSession *)session state:(FBSessionState) state error:(NSError *)error {
    switch (state) {
        case FBSessionStateOpen: {
            DebugLog(@"open");
            [self checkPermissions];
            [self saveFacebookID];
            break;
        }
        case FBSessionStateClosed: {
            DebugLog(@"closed");
            break;
        }
        case FBSessionStateClosedLoginFailed: {
            DebugLog(@"login failed");
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailToConnectToFacebook object:nil];

            [self removeFacebookAccess];

            break;
        }
        default:
        break;
    }

    if (error) {
        UIAlertView *alertView = [[UIAlertView alloc]
                                  initWithTitle:@"Error"
                                  message:error.localizedDescription
                                  delegate:nil
                                  cancelButtonTitle:@"OK"
                                  otherButtonTitles:nil];
        [alertView show];
    }    
}

+ (void)saveFacebookID {
    [FBRequestConnection startForMeWithCompletionHandler:^(FBRequestConnection *connection, id data, NSError *error) {
        if (error) {
            DebugLog(@"Error requesting /me %@", error);
            return;
        }
        // DebugLog(@"data about current user %@", data);
        NSDictionary *userData = (NSDictionary *)data;
        DebugLog(@"data about current user %@", userData);

        NSNumberFormatter * f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        NSNumber * facebookID = [f numberFromString:userData[@"id"]];
        DebugLog(@"fb id %@", facebookID);

        [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
    }];
}

+ (void)openSession {
    [FBSession openActiveSessionWithReadPermissions:nil
                                       allowLoginUI:YES
                                  completionHandler:
     ^(FBSession *session,
       FBSessionState state, NSError *error) {
         [self sessionStateChanged:session state:state error:error];
     }];
}

+ (void)removeFacebookAccess {
    [FBSession.activeSession closeAndClearTokenInformation];
}

@end
