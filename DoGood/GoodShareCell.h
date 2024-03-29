@class DGFacebookManager;
@class DGTwitterManager;

@interface GoodShareCell : UITableViewCell {
}

- (void)doGood;
- (void)facebook;
- (void)twitter;

@property (weak, nonatomic) IBOutlet UILabel *type;
@property (weak, nonatomic) IBOutlet UISwitch *share;
@property (retain, nonatomic) DGFacebookManager *facebookManager;
@property (retain, nonatomic) DGTwitterManager *twitterManager;

@end
