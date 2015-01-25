#import "DGToDoListViewController.h"

@interface DGToDoListViewController ()

@end

@implementation DGToDoListViewController

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        self.title = @"To Do";
        self.navigationItem.title = self.title;
        self.tabBarItem.image = [UIImage imageNamed:@"tab_todo"];
        self.tabBarItem.selectedImage = [UIImage imageNamed:@"tab_todo"];
    }
    return self;
}

#pragma mark - UIViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.navigationItem.title = @"To Do";
    self.title = self.navigationItem.title;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

@end
