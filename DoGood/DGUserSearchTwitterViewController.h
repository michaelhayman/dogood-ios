#import "DGUserSearchNetworksViewController.h"
@class DGTwitterManager;

@interface DGUserSearchTwitterViewController : DGUserSearchNetworksViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *users;
    DGTwitterManager *twitterManager;
}

@property BOOL disableSelection;

@end
