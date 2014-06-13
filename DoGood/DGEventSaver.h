@import EventKit;

@interface DGEventSaver : NSObject

@property (nonatomic, retain) EKEventStore *eventStore;
@property BOOL hasAccessToEventsStore;

- (void)createEventWithTitle:(NSString *)title notes:(NSString *)notes url:(NSURL *)url startDate:(NSDate *)aStartDate duration:(NSInteger)duration completion:(void (^)(NSString *eventIdentifier, NSError *error))completion;

@end
