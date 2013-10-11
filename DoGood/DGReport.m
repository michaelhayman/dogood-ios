#import "DGReport.h"

@implementation DGReport

+ (void)fileReportFor:(NSNumber *)reportableID ofType:(NSString *)reportableType inController:(UINavigationController *)controller {
    DGReport *report = [DGReport new];
    report.reportable_id = reportableID;
    report.reportable_type = reportableType;

    [[RKObjectManager sharedManager] postObject:report path:@"/reports" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Report sent.", nil)
                                           subtitle:nil
                                   type:TSMessageNotificationTypeSuccess];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
        [TSMessage showNotificationInViewController:controller
                                  title:NSLocalizedString(@"Report not sent.", nil)
                                subtitle:nil
                                   type:TSMessageNotificationTypeError];
    }];
}

@end
