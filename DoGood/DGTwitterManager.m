#import "DGTwitterManager.h"
#import <SocialAuth/SocialAuth.h>
#import <Social/Social.h>

@interface DGTwitterManager () <UIActionSheetDelegate>
@property (nonatomic, readonly, strong) SAAccountStore *accountStore;
@end

@implementation DGTwitterManager

@synthesize accountStore = _accountStore;

#pragma mark - Initialization
- (id)init {
    self = [super init];
    if (self) {
        postOptions = nil;
        [self setupErrors];
    }
    return self;
}

- (SAAccountStore *) accountStore {
	if (!_accountStore) {
        _accountStore = [SAAccountStore new];
	}
	return _accountStore;
}

- (void)setupErrors {
   NSDictionary *unableToPostErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to post", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Twitter may be down or insufficient permissions?", nil)
    };
    unableToPostError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:unableToPostErrorInfo];

    NSDictionary *noAccountErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"No Account", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"The operation timed out.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"Try checking Settings > Twitter.", nil)
    };
    noAccountError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:noAccountErrorInfo];

    NSDictionary *checkSettingsErrorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Unable to Access Twitter", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Access denied.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(@"There are no Twitter accounts configured or Do Good access is disabled on this device. Check Settings > Twitter and try again.", nil)
    };
    checkSettingsError = [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:checkSettingsErrorInfo];
}

- (NSError *)responseErrorWithResponseCode:(NSInteger)code {
    NSString *statusCodeMsg = [NSString stringWithFormat:@"The response status code is %d", code];
    NSDictionary *errorInfo = @{
        NSLocalizedDescriptionKey: NSLocalizedString(@"Response error", nil),
        NSLocalizedFailureReasonErrorKey: NSLocalizedString(@"Access denied.", nil),
        NSLocalizedRecoverySuggestionErrorKey: NSLocalizedString(statusCodeMsg, nil)
    };
    return [NSError errorWithDomain:DGErrorDomain code:-57 userInfo:errorInfo];
}

#pragma mark - Posting
- (void)checkTwitterPostAccessWithSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *error))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    DebugLog(@"post options %@", postOptions);
   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            success(@"Woot");
        } else {
            failure(unableToPostError);
        }
    }];
}

- (void)promptForPostAccess {
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"No Access" message:@"There are no Twitter accounts configured, or Do Good access is disabled. Check Settings > Twitter and try again." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alertView show];
}

- (void)postToTwitter:(NSString *)status andImage:(UIImage *)image withSuccess:(void (^)(NSString *msg))success failure:(void (^)(NSError *postError))failure {
    ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
    DebugLog(@"post options %@", postOptions);

   	[self.accountStore requestAccountTyped:accountType withOptions:postOptions  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com"
                               @"/1.1/statuses/update.json"];
            NSDictionary *params = @{@"status" : status};

            SLRequest *request =
            [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodPOST URL:url parameters:params];

            [request setAccount:account];

            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                DebugLog(@"error %@\n url %@", error, urlResponse);
                NSDictionary *response = [NSJSONSerialization JSONObjectWithData:responseData options:kNilOptions error:nil];
                DebugLog(@"Twitter Response : %@",response);

                if (!error) {
                    success(@"posted good!");
                    [self saveTwitterID:[self getTwitterIDFromAccount:account]];
                    // [self findFacebookIDForAccount:account withSuccess:nil failure:nil];
                } else {
                    failure(unableToPostError);
                }
            }];
        } else {
            failure(noAccountError);
        }
    }];
}

- (void)findTwitterFriendsWithSuccess:(void (^)(NSArray *msg))success failure:(void (^)(NSError *findError))failure {
   	ACAccountType *accountType = [self.accountStore accountTypeWithAccountTypeIdentifier:ACAccountTypeIdentifierTwitter];
   	[self.accountStore requestAccountTyped:accountType withOptions:nil  completion:^(BOOL didFinish, ACAccount *account, NSError *error) {
		if (account) {
            NSString *twitterID = [self getTwitterIDFromAccount:account];
            [[DGUser currentUser] saveSocialID:twitterID withType:@"twitter"];

            NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/friends/ids.json"];
            NSDictionary *params = @{@"user_id" : twitterID };

            SLRequest *request = [SLRequest requestForServiceType:SLServiceTypeTwitter requestMethod:SLRequestMethodGET URL:url parameters:params];
            [request setAccount:account];

            [request performRequestWithHandler:^(NSData *responseData, NSHTTPURLResponse *urlResponse, NSError *error) {
                 // DebugLog(@"%@",[[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding]);
                 if (responseData) {
                     if (urlResponse.statusCode >= 200 && urlResponse.statusCode < 300) {
                         NSError *jsonError;
                         NSDictionary *statusData = [NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingAllowFragments error:&jsonError];

                         if (statusData) {
                             NSArray *twitterUserIDs= [statusData valueForKey:@"ids"];
                             success(twitterUserIDs);
                         } else {
                             failure(jsonError);
                         }
                     } else {
                         failure([self responseErrorWithResponseCode:urlResponse.statusCode]);
                     }
                 } else {
                     failure(error);
                 }
             }];
        } else {
            failure(noAccountError);
        }
    }];
}

- (NSString *)getTwitterIDFromAccount:(ACAccount *)account {
    NSDictionary *tempDict = [[NSMutableDictionary alloc] initWithDictionary: [account dictionaryWithValuesForKeys:[NSArray arrayWithObject:@"properties"]]];
    NSString *twitterID = [[tempDict objectForKey:@"properties"] objectForKey:@"user_id"];
    return twitterID;
}

- (void)saveTwitterID:(NSString *)twitterID {
    [[DGUser currentUser] saveSocialID:twitterID withType:@"twitter"];
}

@end
