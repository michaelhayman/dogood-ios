@interface DGReport : NSObject

@property (retain) NSNumber *reportID;
@property (retain) NSString *reportable_type;
@property (retain) NSNumber *reportable_id;

+ (void)fileReportFor:(NSNumber *)reportableID ofType:(NSString *)reportableType inController:(UINavigationController *)controller;

@end
