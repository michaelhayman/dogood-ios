#import "DGCategories.h"
#import "DGCategory.h"

@implementation DGCategories

static NSArray *categoryList = nil;

@synthesize categories;

#pragma mark Singleton Methods

+ (id)sharedManager {
    static DGCategories *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

/*
+ (NSArray *)getCategories {
    [[RKObjectManager sharedManager] getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        categoryList = [[NSArray alloc] initWithArray:mappingResult.array];
        return categoryList;
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        // DGCategory *
        // return a fake array
        // return [NSArray arrayWithObjects:@"Health", , nil]
        DebugLog(@"Operation failed with error: %@", error);
        categories = nil;
    }];

}
 */

/*
- (id)init {
    if (self = [super init]) {
        [[RKObjectManager sharedManager] getObjectsAtPath:@"/categories" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            categories = [[NSArray alloc] initWithArray:mappingResult.array];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            // DGCategory *
            // return a fake array
            // return [NSArray arrayWithObjects:@"Health", , nil]
            DebugLog(@"Operation failed with error: %@", error);
            categories = nil;
        }];
    }
    return self;
}
*/
/*
- (id)init {
    if (self = [super init]) {
        NSArray *tempCategories = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"Categories" ofType:@"plist"]];

        // DebugLog(@"tempcategories %@", tempCategories);
        NSMutableArray *array = [[NSMutableArray alloc] init];

        for (NSDictionary *dict in tempCategories) {
            DGCategory *category = [DGCategory new];
            category.displayName = [dict objectForKey:@"categoryName"];
            category.categoryID = [dict objectForKey:@"categoryID"];
            [array addObject:category];
        }
        // DebugLog(@"array %@", array);
        categories = array;
        // DGCategory *cat = [categories objectAtIndex:0];
        // DebugLog(@"hey %@ %@", cat.displayName, cat.categoryID);
    }
    return self;
}
*/

- (void)dealloc {
    // Should never be called, but just here for clarity really.
}

@end
