#import "DGUserSearchNetworksViewController.h"

@interface DGUserSearchAddressBookViewController : DGUserSearchNetworksViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *users;
}

@property BOOL disableSelection;

@end
