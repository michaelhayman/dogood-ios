#import "DGUserSearchNetworksViewController.h"
@class DGFacebookManager;

@interface DGUserSearchFacebookViewController : DGUserSearchNetworksViewController <UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate> {
    NSArray *users;
    DGFacebookManager *facebookManager;
}

@end
