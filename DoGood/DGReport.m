#import "DGReport.h"

@implementation DGReport

+ (void)fileReportFor:(NSNumber *)reportableID ofType:(NSString *)reportableType inController:(UINavigationController *)controller {
    NSDictionary *reportDict = [NSDictionary dictionaryWithObjectsAndKeys:reportableID, @"reportable_id", reportableType, @"reportable_type", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:reportDict, @"report", nil];

    [[RKObjectManager sharedManager] postObject:nil path:@"/reports" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [DGMessage showSuccessInViewController:controller
                                  title:NSLocalizedString(@"Report sent.", nil)
                                           subtitle:nil];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [DGMessage showErrorInViewController:controller
                                  title:NSLocalizedString(@"Report not sent.", nil)
                               subtitle:[error localizedDescription]];
    }];
}

@end
