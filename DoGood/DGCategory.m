#import <Parse/PFObject+Subclass.h>
#import "DGCategory.h"

@implementation DGCategory

@dynamic displayName;

+ (NSString *)parseClassName {
    return @"DGCategory";
}

@end