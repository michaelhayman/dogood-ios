@interface DGNominee : NSObject

@property (retain) NSNumber *nomineeID;
@property (retain) NSString *full_name;
@property (retain) NSString *email;
@property (retain) NSString *phone;
@property (retain) NSNumber *user_id;
@property (retain) NSString *twitter_id;
@property (retain) NSString *facebook_id;
@property (retain) UIImage *avatarImage;
@property (retain) NSString *avatar;

- (void)configureForUser:(DGUser *)user;

@end
