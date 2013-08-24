#import "DGUserSearchNetworksViewController.h"

@interface DGUserSearchTwitterViewController : DGUserSearchNetworksViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *users;
}

@end
