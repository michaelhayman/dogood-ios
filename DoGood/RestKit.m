#import "RestKit.h"
// models
#import "DGGood.h"
#import "DGNominee.h"
#import "DGCategory.h"
#import "DGComment.h"
#import "DGError.h"
#import "DGFollow.h"
#import "DGVote.h"
#import "DGReward.h"
#import "DGReport.h"
#import "DGTag.h"
#import "DGEntity.h"
#import "DGRKObjectRequestOperation.h"

@implementation RestKit

+ (void)setupRestKit {
    #if DEVELOPMENT_LOGS
        RKLogConfigureByName("RestKit", RKLogLevelTrace);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    #endif

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:JSON_API_HOST_ADDRESS];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(connectionFailedWithOperation:) name:DGConnectionFailure object:nil];

    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
    [[RKObjectManager sharedManager] registerRequestOperationClass:[DGRKObjectRequestOperation class]];

    [DGUser setAuthorizationHeader];

    // --------------------------------
    // user
    // --------------------------------
    RKObjectMapping *userMapping = [RKObjectMapping mappingForClass:[DGUser class]];

    [userMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"userID",
    }];
    [userMapping addAttributeMappingsFromArray:@[
     @"points",
     @"full_name",
     @"phone",
     @"location",
     @"biography",
     @"email",
     @"avatar",
     @"followers_count",
     @"following_count",
     @"current_user_following",
     @"liked_goods_count",
     @"posted_or_followed_goods_count",
     @"contactable",
     @"message",
     @"twitter_id",
     @"facebook_id"
     ]];

    RKResponseDescriptor *userResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:userMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"user" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:userResponseDescriptor];

    RKObjectMapping* userRequestMapping = [RKObjectMapping requestMapping ];
    [userRequestMapping addAttributeMappingsFromArray:@[
     @"email",
     @"password",
     @"full_name",
     @"phone",
     @"contactable",
     @"location",
     @"biography",
     @"twitter_id",
     @"facebook_id"
     ]];

    RKRequestDescriptor *userRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:userRequestMapping objectClass:[DGUser class] rootKeyPath:@"user" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:userRequestDescriptor];

    // --------------------------------
    // nominee
    // --------------------------------
    RKObjectMapping *nomineeMapping = [RKObjectMapping mappingForClass:[DGNominee class]];

    [nomineeMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"nomineeID",
    }];
    NSArray *nomineeArray = @[
      @"full_name",
      @"twitter_id",
      @"facebook_id",
      @"email",
      @"phone",
      @"user_id"
    ];
    [nomineeMapping addAttributeMappingsFromArray:nomineeArray];

    RKResponseDescriptor *nomineeResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:nomineeMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"nominee" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:nomineeResponseDescriptor];

    RKObjectMapping* nomineeRequestMapping = [RKObjectMapping requestMapping];
    [nomineeRequestMapping addAttributeMappingsFromArray:nomineeArray];

    RKRequestDescriptor *nomineeRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:nomineeRequestMapping objectClass:[DGNominee class] rootKeyPath:@"nominee" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:nomineeRequestDescriptor];

    // --------------------------------
    // vote
    // --------------------------------
    RKObjectMapping *voteMapping = [RKObjectMapping mappingForClass:[DGVote class]];
    [voteMapping addAttributeMappingsFromArray:@[
        @"voteable_id", @"voteable_type", @"user_id"
    ]];
    RKResponseDescriptor *voteResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:voteMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"votes" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:voteResponseDescriptor];

    RKObjectMapping* voteRequestMapping = [RKObjectMapping requestMapping ];
    [voteRequestMapping addAttributeMappingsFromArray:@[
     @"voteable_id",
     @"voteable_type",
     @"user_id"
    ]];
    RKRequestDescriptor *voteRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:voteRequestMapping objectClass:[DGVote class] rootKeyPath:@"vote" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:voteRequestDescriptor];

    // --------------------------------
    // entity
    // --------------------------------
    RKObjectMapping *entityMapping = [RKObjectMapping mappingForClass:[DGEntity class]];
    /*
    [entityMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"entityID",
    }];
    */
    /*
    NSDictionary *entityDict = @{
        @"id" : @"entityID",
        @"entityable_type" : @"type",
        @"entityable_id" : @"entityable_id",
        @"link" : @"link",
        @"range" : @"range",
    };
    [entityMapping addAttributeMappingsFromDictionary:entityDict];
    */

    NSArray *entityArray = @[
        @"entityable_type",
        @"entityable_id",
        @"title",
        @"link",
        @"link_id",
        @"link_type",
        @"range"
    ];
    [entityMapping addAttributeMappingsFromArray:entityArray ];
    RKResponseDescriptor *entityResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:entityMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"entities" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:entityResponseDescriptor];

    RKObjectMapping* entityRequestMapping = [RKObjectMapping requestMapping ];
    [entityRequestMapping addAttributeMappingsFromArray:entityArray];
    RKRequestDescriptor *entityRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:entityRequestMapping objectClass:[DGEntity class] rootKeyPath:@"entities" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:entityRequestDescriptor];
    

    // --------------------------------
    // tag
    // --------------------------------
    RKObjectMapping *tagMapping = [RKObjectMapping mappingForClass:[DGTag class]];

    [tagMapping addAttributeMappingsFromDictionary:@{
     @"id" : @"tagID",
    }];
    [tagMapping addAttributeMappingsFromArray:@[
     @"name"
    ]];
    RKResponseDescriptor *tagResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:tagMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"tags" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:tagResponseDescriptor];

    // --------------------------------
    // follow
    // --------------------------------
    RKObjectMapping *followMapping = [RKObjectMapping mappingForClass:[DGFollow class]];

    [followMapping addAttributeMappingsFromArray:@[
     @"followable_id",
     @"followable_type",
     @"user_id"
    ]];
    RKResponseDescriptor *followResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:followMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"follows" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:followResponseDescriptor];

    RKObjectMapping* followRequestMapping = [RKObjectMapping requestMapping ];
    [followRequestMapping addAttributeMappingsFromArray:@[ @"followable_id", @"followable_type", @"user_id" ]];
    RKRequestDescriptor *followRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:followRequestMapping objectClass:[DGFollow class] rootKeyPath:@"follow" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:followRequestDescriptor];

    // --------------------------------
    // comment
    // --------------------------------
    RKObjectMapping *commentMapping = [RKObjectMapping mappingForClass:[DGComment class]];
 
    [commentMapping addAttributeMappingsFromArray:@[
     @"comment",
     @"user_id",
     @"created_at"
    ]];
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    RKResponseDescriptor *commentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"comments" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entities" toKeyPath:@"entities" withMapping:entityMapping]];
    [objectManager addResponseDescriptor:commentResponseDescriptor];

    RKObjectMapping* commentRequestMapping = [RKObjectMapping requestMapping ];
    [commentRequestMapping addAttributeMappingsFromArray:@[
     @"comment",
     @"commentable_id",
     @"commentable_type",
     @"user_id"
    ]];
    RKRequestDescriptor *commentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:commentRequestMapping objectClass:[DGComment class] rootKeyPath:@"comment" method:RKRequestMethodAny];
    [commentRequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entities" toKeyPath:@"entities_attributes" withMapping:entityRequestMapping]];
    [objectManager addRequestDescriptor:commentRequestDescriptor];

    // --------------------------------
    // reward
    // --------------------------------
    RKObjectMapping *rewardMapping = [RKObjectMapping mappingForClass:[DGReward class]];
 
    [rewardMapping addAttributeMappingsFromDictionary:@{ @"id" : @"rewardID" }];
    [rewardMapping addAttributeMappingsFromArray:@[ @"title", @"subtitle", @"teaser", @"full_description", @"user_id", @"cost", @"quantity", @"quantity_remaining", @"instructions" ]];
    // [rewardMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:rewardMapping]];
    RKResponseDescriptor *rewardResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:rewardMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"rewards" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:rewardResponseDescriptor];

    RKObjectMapping* claimRewardRequestMapping = [RKObjectMapping requestMapping ];
    [claimRewardRequestMapping addAttributeMappingsFromDictionary:@{ @"rewardID" : @"id" }];
    RKRequestDescriptor *claimRewardRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:claimRewardRequestMapping objectClass:[DGReward class] rootKeyPath:@"reward" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:claimRewardRequestDescriptor];

    // --------------------------------
    // categories
    // --------------------------------
    RKObjectMapping *categoryMapping = [RKObjectMapping mappingForClass:[DGCategory class]];
    [categoryMapping addAttributeMappingsFromArray:@[
     @"name",
     @"name_constant",
     @"colour",
     @"image_url"
    ]];
    [categoryMapping addAttributeMappingsFromDictionary:@{ @"id" : @"categoryID" }];
    RKResponseDescriptor *categoryResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:categoryMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"categories" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:categoryResponseDescriptor];

    // --------------------------------
    // goods
    // --------------------------------
    RKObjectMapping *goodMapping = [RKObjectMapping mappingForClass:[DGGood class]];

    [goodMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"goodID",
     }];
    [goodMapping addAttributeMappingsFromArray:@[
     @"caption",
     @"current_user_liked",
     @"current_user_commented",
     @"current_user_regooded",
     @"likes_count",
     @"location_name",
     @"location_image",
     @"lat",
     @"lng",
     @"regoods_count",
     @"comments_count",
     @"evidence",
     @"done"
    ]];

    RKResponseDescriptor *goodResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:goodMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"goods" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"nominee" toKeyPath:@"nominee" withMapping:nomineeMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:commentMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"category" withMapping:categoryMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entities" toKeyPath:@"entities" withMapping:entityMapping]];
    [objectManager addResponseDescriptor:goodResponseDescriptor];

    RKObjectMapping* goodRequestMapping = [RKObjectMapping requestMapping];
    [goodRequestMapping addAttributeMappingsFromArray:@[ @"caption", @"category_id", @"location_name", @"location_image", @"lat", @"lng" ]];
    [goodRequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"entities" toKeyPath:@"entities_attributes" withMapping:entityRequestMapping]];
    [goodRequestMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"nominee" toKeyPath:@"nominee_attributes" withMapping:nomineeRequestMapping]];
    RKRequestDescriptor *goodRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:goodRequestMapping objectClass:[DGGood class] rootKeyPath:@"good" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:goodRequestDescriptor];

    // --------------------------------
    // report
    // --------------------------------
    RKObjectMapping *reportMapping = [RKObjectMapping mappingForClass:[DGReport class]];

    [reportMapping addAttributeMappingsFromDictionary:@{
        @"id" : @"reportID",
     }];
    [reportMapping addAttributeMappingsFromArray:@[
     @"reportable_type",
     @"reportable_id"
    ]];

    RKResponseDescriptor *reportResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:reportMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"reports" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:reportResponseDescriptor];

    RKObjectMapping* reportRequestMapping = [RKObjectMapping requestMapping];
    [reportRequestMapping addAttributeMappingsFromArray:@[ @"reportable_type", @"reportable_id" ]];
    RKRequestDescriptor *reportRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:reportRequestMapping objectClass:[DGReport class] rootKeyPath:@"report" method:RKRequestMethodAny];
    [objectManager addRequestDescriptor:reportRequestDescriptor];

    // --------------------------------
    // error
    // --------------------------------
    RKObjectMapping *errorMapping = [RKObjectMapping mappingForClass:[DGError class]];
    [errorMapping addAttributeMappingsFromDictionary:@{
        @"messages" : @"messages",
     }];
    RKResponseDescriptor *errorResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:errorMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"errors" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassClientError)];
    [objectManager addResponseDescriptor:errorResponseDescriptor];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGConnectionFailure object:nil];
}

+ (void)connectionFailedWithOperation:(NSNotification *)notification {
    RKObjectRequestOperation *operation = (RKObjectRequestOperation *)notification.object;
    DebugLog(@"failed!");
    UINavigationController *nav = (UINavigationController *)[[UIApplication sharedApplication] keyWindow].rootViewController;

    if (operation) {

        NSInteger statusCode = operation.HTTPRequestOperation.response.statusCode;
        DebugLog(@"failed! %i", statusCode);

        switch (statusCode) {
            case 0: // no internet connection
            {
                [TSMessage showNotificationInViewController:nav title:@"Couldn't connect" subtitle:@"No internet connection" type:TSMessageNotificationTypeError];
            }
                break;
            case  401: // not authenticated
            {
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidFailSilentAuthenticationNotification object:nil];
                DebugLog(@"present create account/sign up screen");
            }
                break;

            default:
            {
            }
                break;
        }
    }
}

@end
