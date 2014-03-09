#import "DGFollow.h"

@implementation DGFollow

+ (void)followType:(NSString *)followableType withID:(NSNumber *)followableID inController:(UINavigationController *)controller withSuccess:(SuccessBlock)success failure:(ErrorBlock)failure {
    NSDictionary *params = [self buildParamsForType:followableType withID:followableID];

    [[RKObjectManager sharedManager] postObject:nil path:@"/follows" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateFollowingsNotification object:nil];
        success(YES, @"User followed.");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Follow not registered.", nil)
                                subtitle:nil
                                   type:TSMessageNotificationTypeError];
        failure(error);
    }];
}

+ (void)unfollowType:(NSString *)followableType withID:(NSNumber *)followableID inController:(UINavigationController *)controller withSuccess:(SuccessBlock)success failure:(ErrorBlock)failure {
    NSDictionary *params = [self buildParamsForType:followableType withID:followableID];

    [[RKObjectManager sharedManager] deleteObject:nil path:[NSString stringWithFormat:@"/follows/%@", followableID] parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidUpdateFollowingsNotification object:nil];
        success(YES, @"User unfollowed.");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Follow not registered.", nil)
                                subtitle:nil
                                   type:TSMessageNotificationTypeError];
        failure(error);
    }];
}

+ (NSDictionary *)buildParamsForType:(NSString *)followableType withID:(NSNumber *)followableID {
    NSDictionary *followDict = [NSDictionary dictionaryWithObjectsAndKeys:followableID, @"followable_id", followableType, @"followable_type", nil];
    return [NSDictionary dictionaryWithObjectsAndKeys:followDict, @"follow", nil];
}

@end
