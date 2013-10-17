#import "RestKit.h"
// models
#import "DGGood.h"
#import "DGCategory.h"
#import "DGComment.h"
#import "DGError.h"
#import "DGFollow.h"
#import "DGVote.h"
#import "DGReward.h"
#import "DGReport.h"
#import "DGTag.h"

@implementation RestKit

+ (void)setupRestKit {
    #ifdef DEVELOPMENT_LOGS
        RKLogConfigureByName("RestKit", RKLogLevelTrace);
        RKLogConfigureByName("RestKit/ObjectMapping", RKLogLevelInfo);
        RKLogConfigureByName("RestKit/Network", RKLogLevelTrace);
    #endif

    [AFNetworkActivityIndicatorManager sharedManager].enabled = YES;
    NSURL *baseURL = [NSURL URLWithString:JSON_API_HOST_ADDRESS];
    AFHTTPClient* client = [[AFHTTPClient alloc] initWithBaseURL:baseURL];
    
    [client setDefaultHeader:@"Accept" value:RKMIMETypeJSON];

    RKObjectManager *objectManager = [[RKObjectManager alloc] initWithHTTPClient:client];
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
     @"username",
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
     @"username",
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
     @"user_id"
    ]];
    [commentMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"user" toKeyPath:@"user" withMapping:userMapping]];
    RKResponseDescriptor *commentResponseDescriptor = [RKResponseDescriptor responseDescriptorWithMapping:commentMapping method:RKRequestMethodAny pathPattern:nil keyPath:@"comments" statusCodes:RKStatusCodeIndexSetForClass(RKStatusCodeClassSuccessful)];
    [objectManager addResponseDescriptor:commentResponseDescriptor];

    RKObjectMapping* commentRequestMapping = [RKObjectMapping requestMapping ];
    [commentRequestMapping addAttributeMappingsFromArray:@[
     @"comment",
     @"commentable_id",
     @"commentable_type",
     @"user_id"
    ]];
    RKRequestDescriptor *commentRequestDescriptor = [RKRequestDescriptor requestDescriptorWithMapping:commentRequestMapping objectClass:[DGComment class] rootKeyPath:@"comment" method:RKRequestMethodAny];
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
     @"name"
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
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"comments" toKeyPath:@"comments" withMapping:commentMapping]];
    [goodMapping addPropertyMapping:[RKRelationshipMapping relationshipMappingFromKeyPath:@"category" toKeyPath:@"category" withMapping:categoryMapping]];
    [objectManager addResponseDescriptor:goodResponseDescriptor];

    RKObjectMapping* goodRequestMapping = [RKObjectMapping requestMapping];
    [goodRequestMapping addAttributeMappingsFromArray:@[ @"caption", @"category_id", @"location_name", @"location_image", @"lat", @"lng" ]];
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

@end
