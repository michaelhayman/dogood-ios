#import "constants.h"

#pragma mark - Errors -----

NSString *const DGErrorDomain = @"DGErrorDomain";

#pragma mark - User Constants -----

NSString* const kDGUserCurrentUserIDDefaultsKey = @"kDGUserCurrentUserIDDefaultsKey";
NSString* const kDGUserCurrentUserEmail = @"kDGUserCurrentUserEmail";
NSString* const kDGUserCurrentUserPoints = @"kDGUserCurrentUserPoints";
NSString* const kDGUserCurrentUserFullName = @"kDGUserCurrentUserFullName";
NSString* const kDGUserCurrentUserLocation = @"kDGUserCurrentUserLocation";
NSString* const kDGUserCurrentUserBiography = @"kDGUserCurrentUserBiography";
NSString* const kDGUserCurrentUserPhone = @"kDGUserCurrentUserPhone";
NSString* const kDGUserCurrentUserContactable = @"kDGUserCurrentUserContactable";
NSString* const kDGUserCurrentUserAvatar = @"kDGUserCurrentUserAvatar";
NSString* const kDGUserCurrentUserTwitterID = @"kDGUserCurrentUserTwitterID";
NSString* const kDGUserCurrentUserFacebookID = @"kDGUserCurrentUserFacebookID";

#pragma mark - UITableViewCells -----

NSString* const UITextFieldCellIdentifier = @"UITextFieldCell";

#pragma mark - Notifications ------

NSString* const DGConnectionFailure = @"DGConnectionFailure";

NSString* const DGUserDidSignOutNotification = @"DGUserDidSignOutNotification";
NSString *const DGUserDidFailSilentAuthenticationNotification = @"DGUserDidFailSilentAuthenticationNotification";
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
NSString* const DGUserDidChangeFollowOnUser = @"DGUserDidChangeFollowOnUser";
NSString* const DGUserInfoDidLoad = @"DGUserInfoDidLoad";

NSString* const DGUserDidSelectRewards = @"DGUserDidSelectRewards";
NSString* const DGUserUpdatePointsNotification = @"DGUserUpdatePointsNotification";
NSString* const DGUserDidUpdatePointsNotification = @"DGUserDidUpdatePointsNotification";
NSString* const DGUserClaimRewardNotification = @"DGUserClaimRewardNotification";
NSString* const DGUserDidClaimRewardNotification = @"DGUserDidClaimRewardNotification";

NSString* const DGUserDidChangePhoto = @"DGUserDidChangePhoto";

NSString* const DGUserDidConnectToTwitter = @"DGUserDidConnectToTwitter";
NSString* const DGUserDidDisconnectFromTwitter = @"DGUserDidDisconnectFromTwitter";
NSString* const DGUserIsConnectedToTwitter = @"DGUserIsConnectedToTwitter";
NSString* const DGUserIsNotConnectedToTwitter = @"DGUserIsDisconnectedFromFromTwitter";
NSString* const DGUserDidCheckIfTwitterIsConnected = @"DGUserDidCheckIfTwitterIsConnected";
NSString* const DGUserDidFindFriendsOnTwitter = @"DGUserDidFindFriendsOnTwitter";
NSString* const DGUserDidFailFindFriendsOnTwitter = @"DGUserDidFailFindFriendsOnTwitter";
NSString* const DGUserDidConnectToFacebook = @"DGUserDidConnectToFacebook";
NSString* const DGUserDidFailToConnectToFacebook = @"DGUserDidFailToConnectToFacebook";
NSString* const DGUserDidDisconnectFromFacebook = @"DGUserDidDisconnectFromFacebook";
NSString* const DGUserDidCheckIfFacebookIsConnectedAndHasPermissions = @"DGUserDidCheckIfFacebookIsConnectedAndHasPermissions";
NSString* const DGUserDidCheckIfFacebookIsConnected = @"DGUserDidCheckIfFacebookIsConnected";
NSString* const DGUserDidFindFriendsOnFacebook = @"DGUserDidFindFriendsOnFacebook";
NSString* const DGUserDidCheckIfAddressBookIsConnected = @"DGUserDidCheckIfAddressBookIsConnected";

NSString* const DGUserDidSelectPersonForTextField = @"DGUserDidSelectPersonForTextField";
NSString* const DGUserDidNotFindPeopleForTextField = @"DGUserDidNotFindPeopleForTextField";
NSString* const DGUserDidSelectTagForTextField = @"DGUserDidSelectTagForTextField";
NSString* const DGUserDidNotFindTagsForTextField = @"DGUserDidNotFindTagsForTextField";

NSString* const DGUserDidStartSearchingTags = @"DGUserDidStartSearchingTags";
NSString* const DGUserDidStartSearchingPeople = @"DGUserDidStartSearchingPeople";
NSString* const DGSearchTextFieldDidBeginEditing = @"DGSearchTextFieldDidBeginEditing";
NSString* const DGSearchTextFieldDidEndEditing = @"DGSearchTextFieldDidEndEditing";
NSString* const DGUserDidStartBrowsingSearchTable = @"DGUserDidStartBrowsingSearchTable";

NSString* const DGNomineeWasChosen = @"DGNomineeWasChosen";
NSString* const ExternalNomineeWasChosen = @"ExternalNomineeWasChosen";
NSString* const DGUserDidPostGood = @"DGUserDidPostGood";
NSString* const DGUserDidChangeFollowOnGood = @"DGUserDidChangeFollowOnGood";
NSString* const DGUserDidChangeVoteOnGood = @"DGUserDidChangeVoteOnGood";

NSString* const DGTourWasRequested = @"DGTourWasRequested";