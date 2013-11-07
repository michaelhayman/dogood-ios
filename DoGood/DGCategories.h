@interface DGCategories : NSObject {
    NSArray *categories;
}

@property (nonatomic, strong) NSArray *categories;

+ (id)sharedManager;

@end
