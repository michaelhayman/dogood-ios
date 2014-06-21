@class DGUser;

@interface DGUserGoodsTableView : UITableView <UITableViewDataSource, UITableViewDelegate> {
}

- (void)initializeTableWithUser:(DGUser *)user;

@property (nonatomic, weak) UINavigationController *navigationController;
@property (nonatomic, strong) DGUser *user;

@end

typedef enum {
    nominationsFor,
    nominationsBy,
    helpWanted,
    follows,
    votes,
    numUserGoodsSections
} UserGoodsSectionType;
