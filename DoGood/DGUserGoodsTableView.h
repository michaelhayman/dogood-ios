@class DGUser;

@interface DGUserGoodsTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
}

- (void)initializeTableWithUser:(DGUser *)user;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, weak) NSNumber *userID;
@property (nonatomic, weak) DGUser *user;

@end

typedef enum {
    nominationsFor,
    nominationsBy,
    helpWanted,
    follows,
    votes,
    numUserGoodsSections
} UserGoodsSectionType;
