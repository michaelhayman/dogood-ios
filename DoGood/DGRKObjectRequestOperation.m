@interface DGRKObjectRequestOperation : RKObjectRequestOperation

@end

@implementation DGRKObjectRequestOperation

- (void)setCompletionBlockWithSuccess:(void ( ^ ) ( RKObjectRequestOperation *operation , RKMappingResult *mappingResult ))success failure:(void ( ^ ) ( RKObjectRequestOperation *operation , NSError *error ))failure
{
    [super setCompletionBlockWithSuccess:^void(RKObjectRequestOperation *operation , RKMappingResult *mappingResult) {
        if (success) {
            success(operation, mappingResult);
        }

    }failure:^void(RKObjectRequestOperation *operation , NSError *error) {

        [[NSNotificationCenter defaultCenter] postNotificationName:DGConnectionFailure object:operation];

        if (failure) {
            failure(operation, error);
        }

    }];
}

@end
