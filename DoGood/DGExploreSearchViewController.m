#import "DGExploreSearchViewController.h"
#import "DGExploreSearchPeopleTableViewController.h"
#import "DGExploreSearchTagsTableViewController.h"
#import "DGExploreViewController.h"

@implementation DGExploreSearchViewController

- (void)viewDidLoad {
    self.title = @"Search";
    [self initTables];
    [self watchKeyboard];
    [self selectPeople:peopleButton];
    tableView.hidden = YES;

    UINib *userNib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:userNib forCellReuseIdentifier:@"UserCell"];

    UINib *tagNib = [UINib nibWithNibName:@"TagCell" bundle:nil];
    [tableView registerNib:tagNib forCellReuseIdentifier:@"TagCell"];

    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];

    [self.searchField addTarget:self action:@selector(searchFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"1. will appear called each time");
    // headerViewToTopConstraint.constant = -30;
    headerViewToTopConstraint.constant = -130;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"memory warning from %@", [self class]);
}

- (void)viewDidAppear:(BOOL)animated {
    DebugLog(@"2. did appear called each time");
    headerViewToTopConstraint.constant = 0;
    [headerView setNeedsUpdateConstraints];

    [UIView animateWithDuration:0.3 animations:^{
        [headerView layoutIfNeeded];
    }];
    [self watchKeyboard];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    headerViewToTopConstraint.constant = -30;
    [headerView layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidStartBrowsingSearchTable object:nil];
}

#pragma mark - Tables
- (void)initTables {
    if (searchPeopleTable == nil) {
        searchPeopleTable = [[DGExploreSearchPeopleTableViewController alloc] init];
    }
    searchPeopleTable.tableView = tableView;
    if (searchTagsTable == nil) {
        searchTagsTable = [[DGExploreSearchTagsTableViewController alloc] init];
    }
    searchTagsTable.tableView = tableView;
    searchTagsTable.navigationController = self.navigationController;
}

#pragma mark - Actions
- (IBAction)selectPeople:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidStartSearchingPeople object:nil];

    [self reselect:peopleButton];
    [self deselect:tagsButton];
    tableView.delegate = searchPeopleTable;
    tableView.dataSource = searchPeopleTable;
    [tableView reloadData];
    [self searchFieldDidChange:nil];
}

- (IBAction)selectTags:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidStartSearchingTags object:nil];

    [self reselect:tagsButton];
    [self deselect:peopleButton];
    tableView.delegate = searchTagsTable;
    tableView.dataSource = searchTagsTable;
    [tableView reloadData];
    [self searchFieldDidChange:nil];
}

- (void)deselect:(UIButton *)button {
    [DGAppearance tabButton:button on:NO withBackgroundColor:EASING andTextColor:MUD];
}

- (void)reselect:(UIButton *)button {
    [DGAppearance tabButton:button on:YES withBackgroundColor:BRILLIANCE andTextColor:MUD];
}

#pragma mark - Keyboard handler
- (void)closeKeyboard {
    [self.parent.searchField resignFirstResponder];
}

- (void)watchKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard) name:DGUserDidStartBrowsingSearchTable object:nil];
}

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)searchFieldDidChange:(id)sender {
    if ([self.searchField.text length] == 0) {
        self.searchField.rightView.hidden = YES;
    } else {
        self.searchField.rightView.hidden = NO;
    }
    if (peopleButton.selected) {
        if ([self.searchField.text length] > 1) {
            tableView.hidden = NO;
            [searchPeopleTable getUsersByName:self.searchField.text];
        } else {
            tableView.hidden = YES;
            [searchPeopleTable purge];
        }
    } else if (tagsButton.selected) {
        if ([self.searchField.text length] > 1) {
            tableView.hidden = NO;
            [searchTagsTable getTagsByName:self.searchField.text];
        } else {
            tableView.hidden = YES;
            [searchTagsTable purge];
        }
    }
}

@end
