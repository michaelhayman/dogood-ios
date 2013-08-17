#import "constants.h"

#pragma mark - User

// Constants
NSString* const kDGUserCurrentUserIDDefaultsKey = @"kDGUserCurrentUserIDDefaultsKey";
NSString* const kDGUserCurrentUserEmail = @"kDGUserCurrentUserEmail";
NSString* const kDGUserCurrentUserUsername = @"kDGUserCurrentUserUsername";
NSString* const kDGUserCurrentUserFullName = @"kDGUserCurrentUserFullName";
NSString* const kDGUserCurrentUserPhone = @"kDGUserCurrentUserPhone";
NSString* const kDGUserCurrentUserContactable = @"kDGUserCurrentUserContactable";

// Notifications
NSString* const DGUserDidSignOutNotification = @"DGUserDidSignOutNotification";

NSString* const DGUserDidSignInNotification = @"DGUserDidSignInNotification";
NSString* const DGUserDidFailSignInNotification = @"DGUserDidFailSignInNotification";

NSString* const DGUserDidCreateAccountNotification = @"DGUserDidCreateAccountNotification";
NSString* const DGUserDidFailCreateAccountNotification = @"DGUserDidFailCreateAccountNotification";

NSString* const DGUserDidUpdateAccountNotification = @"DGUserDidUpdateAccountNotification";
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

#pragma mark - Good

// Notifications

NSString* const DGUserDidPostGood = @"DGUserDidPostGood";
