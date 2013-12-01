@interface DGNominee : NSObject

@property (retain) NSNumber *nomineeID;
@property (retain) NSString *fullName;
@property (retain) NSString *email;
@property (retain) NSString *phone;
@property (retain) NSNumber *user_id;
@property (retain) NSNumber *twitterID;
@property (retain) NSNumber *facebookID;
@property (retain) UIImage *avatarImage;
@property (retain) NSString *avatar;

- (void)configureForUser:(DGUser *)user;

@end
