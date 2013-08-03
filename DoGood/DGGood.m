#import <Parse/PFObject+Subclass.h>
#import "DGGood.h"

@implementation DGGood

@dynamic caption;
@dynamic category;
@dynamic user;
@dynamic location;
@dynamic point;
@dynamic image;
@dynamic shareDoGood;
@dynamic shareFacebook;
@dynamic shareTwitter;

+ (NSString *)parseClassName {
    return @"DGGood";
}

@end
