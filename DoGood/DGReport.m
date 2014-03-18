#import "DGReport.h"

@implementation DGReport

+ (void)fileReportFor:(NSNumber *)reportableID ofType:(NSString *)reportableType inController:(UINavigationController *)controller {
    NSDictionary *reportDict = [NSDictionary dictionaryWithObjectsAndKeys:reportableID, @"reportable_id", reportableType, @"reportable_type", nil];
    NSDictionary *params = [NSDictionary dictionaryWithObjectsAndKeys:reportDict, @"report", nil];

    [[RKObjectManager sharedManager] postObject:nil path:@"/reports" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Report sent.", nil)
                                           subtitle:nil
                                   type:TSMessageNotificationTypeSuccess];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Report not sent.", nil)
                               subtitle:[error localizedDescription]
                                   type:TSMessageNotificationTypeError];
    }];
}

@end
