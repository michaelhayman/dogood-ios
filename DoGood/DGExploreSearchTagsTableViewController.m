#import "DGExploreSearchTagsTableViewController.h"
#import "DGTag.h"
#import "TagCell.h"

@implementation DGExploreSearchTagsTableViewController

- (void)viewDidLoad {
    self.title = @"Search Tags";
    UINib *nib = [UINib nibWithNibName:@"TagCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"TagCell"];

    tableView.delegate = self;
    tableView.dataSource = self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"TagCell";
    TagCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGTag *tag = tags[indexPath.row];
    cell.taggage = tag;
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [tags count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

@end
