#import <Parse/PFObject+Subclass.h>
#import "DGLocation.h"

@implementation DGLocation

@dynamic displayName;
@dynamic point;
@dynamic fourSquareID;
@dynamic category;
@dynamic imageURL;

+ (NSString *)parseClassName {
    return @"DGLocation";
}

@end