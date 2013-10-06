@interface DGCategories : NSObject {
    NSArray *categories;
}

@property (nonatomic, retain) NSArray *categories;

+ (id)sharedManager;

@end
