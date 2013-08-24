#import "FBSession.h"

@interface ThirdParties : NSObject

#pragma mark - Foursquare
// + (void)setupFoursquare;
#pragma mark - Twitter
+ (void)checkTwitterAccess:(bool)prompt;
+ (void)noTwitterAccountMessage;
+ (void)appNotAllowedToAccessTwitterMessage;
+ (void)getTwitterFriendsOnDoGood;
#pragma mark - Facebook
+ (void)postToTwitter:(NSString *)status;
+ (void)facebookHandleDidBecomeActive;
+ (void)postToFacebook:(NSString *)status andImage:(UIImage *)image;
+ (void)checkFacebookAccess;
+ (void)checkFacebookAccessForPosting;
+ (void)checkFacebookAccessForFriends;
+ (bool)facebookHandleOpenURL:(NSURL *)url;
+ (void)removeFacebookAccess;
+ (void)getFacebookFriendsOnDoGood;

@end
