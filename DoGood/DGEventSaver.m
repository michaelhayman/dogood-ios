#import "DGEventSaver.h"
#import <UIAlertView+Blocks/UIAlertView+Blocks.h>

@implementation DGEventSaver

- (EKEventStore *)eventStore {
    if (!_eventStore) {
        _eventStore = [[EKEventStore alloc] init];
    }
    return _eventStore;
}

-(NSDate *)dateToLocalTime:(NSDate *)date {
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = [tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

-(NSDate *)dateToGlobalTime:(NSDate *)date {
    NSTimeZone *tz = [NSTimeZone localTimeZone];
    NSInteger seconds = -[tz secondsFromGMTForDate: date];
    return [NSDate dateWithTimeInterval: seconds sinceDate: date];
}

- (void)createEventWithTitle:(NSString *)title notes:(NSString *)notes url:(NSURL *)url startDate:(NSDate *)aStartDate duration:(NSInteger)duration completion:(void (^)(NSString *eventIdentifier, NSError *error))completion {

    NSString *actionTitle = @"Add Event";
    [UIAlertView showWithTitle:[NSString stringWithFormat:@"Add to your calendar?"] message:@"Would you like to add this event to your calendar?" cancelButtonTitle:@"Cancel" otherButtonTitles:@[actionTitle] tapBlock:^(UIAlertView *alertView, NSInteger buttonIndex) {
         if (buttonIndex == [alertView cancelButtonIndex]) {
             DebugLog(@"Cancelled");
         } else if ([[alertView buttonTitleAtIndex:buttonIndex] isEqualToString:actionTitle]) {
            [self requestAccessToEventStoreWithCompletion:^(BOOL success, NSError *anError) {
                DebugLog(@"instance method");
                if (success) {
                    NSDate *startDate = [self dateToGlobalTime:aStartDate];
                    EKEvent *event = [EKEvent eventWithEventStore:self.eventStore];
                    event.title = title;
                    event.startDate = startDate;
                    event.endDate = startDate;
                    event.notes = notes;
                    event.URL = url;
                    event.allDay = YES;
                    event.calendar = self.eventStore.defaultCalendarForNewEvents;
                    event.alarms = [NSArray arrayWithObject:[EKAlarm alarmWithAbsoluteDate:event.startDate]];
                    NSError *eventError = nil;
                    BOOL created = [self.eventStore saveEvent:event span:EKSpanThisEvent error:&eventError];
                    if (created) {
                        if (completion) {
                            completion(event.eventIdentifier, nil);
                        }
                    } else if (eventError) {
                        if (completion) {
                            completion(nil, eventError);
                        }
                    }

                } else {
                    if (completion) {
                        completion(nil, anError);
                    }
                }
            }];
         }
    }];
}

- (void)requestAccessToEventStoreWithCompletion:(void (^)(BOOL success, NSError *error))completion {
    DebugLog(@"requested access");
    if (!self.hasAccessToEventsStore) {
        DebugLog(@"no access");
        [self.eventStore requestAccessToEntityType:EKEntityTypeEvent completion:^(BOOL granted, NSError *error) {
            if (error) {
                DebugLog(@"error adding event to calendar: %@", [error localizedDescription]);
            }

            self.hasAccessToEventsStore = granted;
            if (completion) {
                completion(granted, error);
                DebugLog(@"completed");
            } else {
                DebugLog(@"not completed");
            }
        }];
    } else {
        DebugLog(@"access granted");
        if (completion) {
            completion(YES, nil);
        }
    }
}

@end
