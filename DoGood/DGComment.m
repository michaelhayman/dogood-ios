#import <Parse/PFObject+Subclass.h>
#import "DGComment.h"

@implementation DGComment

@dynamic body;
@dynamic good;
@dynamic user;

+ (NSString *)parseClassName {
    return @"DGComment";
}

@end
