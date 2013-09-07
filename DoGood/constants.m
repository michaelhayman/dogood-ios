#import "constants.h"

#pragma mark - User

// Constants
NSString* const kDGUserCurrentUserIDDefaultsKey = @"kDGUserCurrentUserIDDefaultsKey";
NSString* const kDGUserCurrentUserEmail = @"kDGUserCurrentUserEmail";
NSString* const kDGUserCurrentUserUsername = @"kDGUserCurrentUserUsername";
NSString* const kDGUserCurrentUserFullName = @"kDGUserCurrentUserFullName";
NSString* const kDGUserCurrentUserLocation = @"kDGUserCurrentUserLocation";
NSString* const kDGUserCurrentUserBiography = @"kDGUserCurrentUserBiography";
NSString* const kDGUserCurrentUserPhone = @"kDGUserCurrentUserPhone";
NSString* const kDGUserCurrentUserContactable = @"kDGUserCurrentUserContactable";
NSString* const kDGUserCurrentUserAvatar = @"kDGUserCurrentUserAvatar";
NSString* const kDGUserCurrentUserTwitterID = @"kDGUserCurrentUserTwitterID";
NSString* const kDGUserCurrentUserFacebookID = @"kDGUserCurrentUserFacebookID";

// Notifications
NSString* const DGUserDidSignOutNotification = @"DGUserDidSignOutNotification";

NSString* const DGUserDidSignInNotification = @"DGUserDidSignInNotification";
NSString* const DGUserDidFailSignInNotification = @"DGUserDidFailSignInNotification";

NSString* const DGUserDidCreateAccountNotification = @"DGUserDidCreateAccountNotification";
NSString* const DGUserDidFailCreateAccountNotification = @"DGUserDidFailCreateAccountNotification";

NSString* const DGUserDidUpdateAccountNotification = @"DGUserDidUpdateAccountNotification";
NSString* const DGUserDidUpdateAvatarNotification = @"DGUserDidUpdateAvatarNotification";
NSString* const DGUserDidFailUpdateAccountNotification = @"DGUserDidFailUpdateAccountNotification";

NSString* const DGUserEmailIsUnique = @"DGUserEmailIsUnique";
NSString* const DGUserEmailIsNotUnique = @"DGUserEmailIsNotUnique";

NSString* const DGUserDidUpdatePasswordNotification = @"DGUserDidUpdatePasswordNotification";
NSString* const DGUserDidFailUpdatePasswordNotification = @"DGUserDidFailUpdatePasswordNotification";

NSString* const DGUserDidSendPasswordNotification = @"DGUserDidSendPasswordNotification";
NSString* const DGUserDidFailSendPasswordNotification = @"DGUserDidFailSendPasswordNotification";

NSString* const DGUserInfoDidLoad = @"DGUserInfoDidLoad";

NSString* const DGUserUpdatePointsNotification = @"DGUserUpdatePointsNotification";
NSString* const DGUserDidUpdatePointsNotification = @"DGUserDidUpdatePointsNotification";

NSString* const DGUserClaimRewardNotification = @"DGUserClaimRewardNotification";

NSString* const DGUserDidAddPhotoNotification = @"DGUserDidAddPhotoNotification";
NSString* const DGUserDidRemovePhotoNotification = @"DGUserDidRemovePhotoNotification";

NSString* const DGUserDidToggleMenu = @"DGUserDidToggleMenu";

#pragma mark - Good

// Notifications

NSString* const DGUserDidPostGood = @"DGUserDidPostGood";

NSString* const DGUserDidUpdateFollowingsNotification = @"DGUserDidUpdateFollowingsNotification";

NSString* const DGUserDidConnectToTwitter = @"DGUserDidConnectToTwitter";
NSString* const DGUserDidDisconnectFromTwitter = @"DGUserDidDisconnectFromTwitter";
NSString* const DGUserIsConnectedToTwitter = @"DGUserIsConnectedToTwitter";
NSString* const DGUserIsNotConnectedToTwitter = @"DGUserIsDisconnectedFromFromTwitter";
NSString* const DGUserDidCheckIfTwitterIsConnected = @"DGUserDidCheckIfTwitterIsConnected";
NSString* const DGUserDidFindFriendsOnTwitter = @"DGUserDidFindFriendsOnTwitter";
NSString* const DGUserDidFailFindFriendsOnTwitter = @"DGUserDidFailFindFriendsOnTwitter";

NSString* const DGUserDidConnectToFacebook = @"DGUserDidConnectToFacebook";
NSString* const DGUserDidDisconnectFromFacebook = @"DGUserDidDisconnectFromFacebook";
NSString* const DGUserDidCheckIfFacebookIsConnectedAndHasPermissions = @"DGUserDidCheckIfFacebookIsConnectedAndHasPermissions";
NSString* const DGUserDidCheckIfFacebookIsConnected = @"DGUserDidCheckIfFacebookIsConnected";
NSString* const DGUserDidFindFriendsOnFacebook = @"DGUserDidFindFriendsOnFacebook";

NSString* const DGUserDidCheckIfAddressBookIsConnected = @"DGUserDidCheckIfAddressBookIsConnected";

// UITableView cells
NSString* const UITextFieldCellIdentifier = @"UITextFieldCell";
