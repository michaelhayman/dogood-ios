#import "DGAppDelegate.h"
// views
#import "NavigationViewController.h"
#import "DGGoodListViewController.h"
// models
#import "DGGood.h"
#import "DGCategory.h"
#import "DGComment.h"
#import "DGError.h"
#import "DGFollow.h"
#import "DGVote.h"
#import "DGReward.h"
// libraries
// #import <NUI/NUIAppearance.h>
// #import "Foursquare-API-v2/Foursquare2.h"

@implementation DGAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // [NUIAppearance init];
    int imageSize = 20;

    UIImage *barBackBtnImg = [[UIImage imageNamed:@"BackButton"] resizableImageWithCapInsets:UIEdgeInsetsMake(20, imageSize, 0, 0)];
    UIImage *barBackBtnImgTap = [[UIImage imageNamed:@"BackButtonTap"] resizableImageWithCapInsets:UIEdgeInsetsMake(10, imageSize, 0, 0)];

    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImg
                                                      forState:UIControlStateNormal
                                                    barMetrics:UIBarMetricsDefault];
    [[UIBarButtonItem appearance] setBackButtonBackgroundImage:barBackBtnImgTap
                                                      forState:UIControlStateHighlighted
                                                    barMetrics:UIBarMetricsDefault];

    UIImage *image = [UIImage imageNamed:@"NavBar.png"];
    [[UINavigationBar appearance] setBackgroundImage:image forBarMetrics:UIBarMetricsDefault];

    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]] ;
    [self setUpUserAuthentication];
    [self setupRestKit];
    [self setupFoursquare];
    [self setupViewsForUser];
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
}

- (void)applicationWillTerminate:(UIApplication *)application {
}

- (void)setupViewsForUser {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGGoodListViewController *goodListController = [storyboard instantiateViewControllerWithIdentifier:@"GoodList"];

    self.window.rootViewController = [[NavigationViewController alloc] initWithRootViewController:goodListController];
    [[UIApplication sharedApplication] setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
}

#pragma mark - User authentication
- (void)setUpUserAuthentication {
    DebugLog(@"set up user auth");
    // Register for authentication notifications
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignInNotification
                                               object:nil];
	[[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(setBasicHTTPAccessFromAuthenticationNotification:)
                                                 name:DGUserDidSignOutNotification
                                               object:nil];

    // [[DGUser currentUser] verifySavedUser];
    [DGUser currentUser];
    [DGUser verifySavedUser];
}

- (void)setBasicHTTPAccessFromAuthenticationNotification:(NSNotification*)notification {
    DebugLog(@"set basic access");
    [DGUser setAuthorizationHeader];
}

#pragma mark - Model setup
- (void)setupRestKit {
    RKLogConfigureByName("RestKit", RKLogLevelTrace);
    RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
    RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:JSON_API_HOST_ADDRESS];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [DGUser setAuthorizationHeader];

    // user
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[DGUser class]];

    [userMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"userID",
        @"username" : @"username",
        @"full_name" : @"full_name",
        @"phone" : @"phone",
        @"email" : @"email",
        @"avatar" : @"avatar",
        @"followers_count" : @"followers_count",
        @"following_count" : @"following_count",
        @"current_user_following" : @"current_user_following",
        @"liked_goods_count" : @"liked_goods_count",
        @"posted_or_followed_goods_count" : @"posted_or_followed_goods_count",
     // @"password" : @"password",
        @"contactable" : @"contactable",
        @"message" : @"message"
     }];
    [userMapping addAttributeMappingsFromArray:@[ @"points" ]];

    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"user" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:userResponseDescriptor];

    RKObjectMapping* userRequestMapping = [RKObjectMapping requestMapping ];
    [userRequestMapping addAttributeMappingsFromArray:@[ @"email", @"username", @"password", @"name", @"phone", @"contactable" ]];
    RKRequestDescriptor *userRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping objectClass:[DGUser class] rootKeyPath:@"user" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:userRequestDescriptor];

    // votes
    RKObjectMapping *voteMapping = [RKObjectMapping mappingForClass:[DGVote class]];

    [voteMapping addAttributeMappingsFromArray:@[
        @"voteable_id", @"voteable_type", @"user_id"
    ]];
    RKResponseDescriptor *voteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:voteMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"votes" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:voteResponseDescriptor];

    RKObjectMapping* voteRequestMapping = [RKObjectMapping requestMapping ];
    [voteRequestMapping addAttributeMappingsFromArray:@[ @"voteable_id", @"voteable_type", @"user_id" ]];
    RKRequestDescriptor *voteRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:voteRequestMapping objectClass:[DGVote class] rootKeyPath:@"vote" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:voteRequestDescriptor];

    // follows
    RKObjectMapping *followMapping = [RKObjectMapping mappingForClass:[DGFollow class]];

    [followMapping addAttributeMappingsFromArray:@[
        @"followable_id", @"followable_type", @"user_id"
    ]];
    RKResponseDescriptor *followResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"follows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:followResponseDescriptor];

    RKObjectMapping* followRequestMapping = [RKObjectMapping requestMapping ];
    [followRequestMapping addAttributeMappingsFromArray:@[ @"followable_id", @"followable_type", @"user_id" ]];
    RKRequestDescriptor *followRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:followRequestMapping objectClass:[DGFollow class] rootKeyPath:@"follow" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:followRequestDescriptor];

    // comments
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[DGComment class]];
 
    [commentMapping addAttributeMappingsFromArray:@[
        @"comment", @"user_id"
    ]];
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    RKResponseDescriptor *commentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"comments" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:commentResponseDescriptor];

    RKObjectMapping* commentRequestMapping = [RKObjectMapping requestMapping ];
    [commentRequestMapping addAttributeMappingsFromArray:@[ @"comment", @"commentable_id", @"commentable_type", @"user_id" ]];
    RKRequestDescriptor *commentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:commentRequestMapping objectClass:[DGComment class] rootKeyPath:@"comment" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:commentRequestDescriptor];

    // rewards
    RKObjectMapping *rewardMapping = [RKObjectMapping mappingForClass:[DGReward class]];
 
    [rewardMapping addAttributeMappingsFromDictionary:@{ @"id" : @"rewardID" }];
    [rewardMapping addAttributeMappingsFromArray:@[ @"title", @"subtitle", @"teaser", @"full_description", @"user_id", @"cost", @"quantity", @"quantity_remaining" ]];
    // [rewardMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:rewardMapping]];
    RKResponseDescriptor *rewardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:rewardMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"rewards" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:rewardResponseDescriptor];

    RKObjectMapping* claimRewardRequestMapping = [RKObjectMapping requestMapping ];
    [claimRewardRequestMapping addAttributeMappingsFromDictionary:@{ @"rewardID" : @"id" }];
    RKRequestDescriptor *claimRewardRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:claimRewardRequestMapping objectClass:[DGReward class] rootKeyPath:@"reward" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:claimRewardRequestDescriptor];

    // good
    RKObjectMapping *goodMapping = [RKObjectMapping mappingForClass:[DGGood class]];

    [goodMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"goodID",
        @"caption" : @"caption",
        @"current_user_liked" : @"current_user_liked",
        @"current_user_commented" : @"current_user_commented",
        @"current_user_regooded": @"current_user_regooded",
        @"likes_count" : @"likes_count",
        @"regoods_count" : @"regoods_count",
        @"comments_count": @"comments_count",
        @"evidence": @"evidence"
     }];

    RKResponseDescriptor *goodResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:goodMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"goods" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:commentMapping]];
    [objectManager addResponseDescriptor:goodResponseDescriptor];

    RKObjectMapping* goodRequestMapping = [RKObjectMapping requestMapping];
    [goodRequestMapping addAttributeMappingsFromArray:@[ @"caption" ]];
    RKRequestDescriptor *goodRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:goodRequestMapping objectClass:[DGGood class] rootKeyPath:@"good" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:goodRequestDescriptor];

    // error
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[DGError class]];
    [errorMapping addAttributeMappingsFromDictionary:@{
        @"messages" : @"messages",
     }];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errors" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [objectManager addResponseDescriptor:errorResponseDescriptor];
}

#pragma mark - Things that don't really belong in here
- (void)listFonts {
    for (NSString* family in [UIFont familyNames])
    {
        NSLog(@"%@", family);

        for (NSString* name in [UIFont fontNamesForFamilyName: family])
        {
            NSLog(@"  %@", name);
        }
    }
}

- (void)setupFoursquare {
    /*
    [Foursquare2 setupFoursquareWithKey:@"EWRCKLKQ4O2LVVYK1ADLNXHTBS3MTYY1JMNPNJCM3SZ1ATII"
                                 secret:@"VZGH0QRJFF4AOU3WTXON0XZZQJ3YKMYLEUQ3ZRCQ0HZBDVTP"
                            callbackURL:@"app://dogood"];
    */
}

@end
