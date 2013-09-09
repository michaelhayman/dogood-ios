#import "DGExploreSearchViewController.h"
#import "DGExploreSearchPeopleTableViewController.h"
#import "DGExploreSearchTagsTableViewController.h"
#import "DGExploreViewController.h"

@implementation DGExploreSearchViewController

- (void)viewDidLoad {
    self.title = @"Search";
    [self initTables];
    [self watchKeyboard];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    UINib *noResultsNib = [UINib nibWithNibName:@"NoResultsCell" bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:@"NoResultsCell"];

    [_searchField addTarget:self action:@selector(searchFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
}

- (void)viewWillAppear:(BOOL)animated {
    DebugLog(@"1. will appear called each time");
    // headerViewToTopConstraint.constant = -30;
    [self selectPeople:peopleButton];
    tableView.hidden = YES;
    headerViewToTopConstraint.constant = -130;
}

- (void)viewWillLayoutSubviews {
    DebugLog(@"- will layout called each time");
}

- (void)viewDidAppear:(BOOL)animated {
    DebugLog(@"2. did appear called each time");
    headerViewToTopConstraint.constant = 0;
    [headerView setNeedsUpdateConstraints];

    [UIView animateWithDuration:5.5 animations:^{
        [headerView layoutIfNeeded];
    }];
}

- (void)viewWillDisappear:(BOOL)animated {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.3];
    [UIView setAnimationCurve:UIViewAnimationCurveEaseInOut];
    headerViewToTopConstraint.constant = -30;
    [headerView layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Tables
- (void)initTables {
    searchPeopleTable = [[DGExploreSearchPeopleTableViewController alloc] init];
    searchPeopleTable.tableView = tableView;
    searchTagsTable = [[DGExploreSearchTagsTableViewController alloc] init];
}

#pragma mark - Actions
- (IBAction)selectPeople:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidStartSearchingPeople object:nil];

    peopleButton.selected = YES;
    tagsButton.selected = NO;
    tableView.delegate = searchPeopleTable;
    tableView.dataSource = searchPeopleTable;
    [tableView reloadData];
    [self searchFieldDidChange:nil];
}

- (IBAction)selectTags:(id)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidStartSearchingTags object:nil];

    peopleButton.selected = NO;
    tagsButton.selected = YES;
    tableView.delegate = searchTagsTable;
    tableView.dataSource = searchTagsTable;
    [tableView reloadData];
    [self searchFieldDidChange:nil];
}

#pragma mark - Keyboard handler
- (void)closeKeyboard {
    [_parent.searchField resignFirstResponder];
}

- (void)watchKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(closeKeyboard) name:DGUserDidStartBrowsingSearchTable object:nil];
}

/*
- (void)dismissKeyboard {
    // [_parent.searchField resignFirstResponder];
    DebugLog(@"dismiss");
    // [_parent.view endEditing:YES];
    // [self.view endEditing:YES];
    [_searchField resignFirstResponder];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    DebugLog(@"kb shown");
    dismissTap = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self
                                   action:@selector(dismissKeyboard)];
    [self.view addGestureRecognizer:dismissTap];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [self.view removeGestureRecognizer:dismissTap];
}

- (void)watchKeyboard {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}
*/

#pragma mark - UITextFieldDelegate methods
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSearchTextFieldDidBeginEditing object:nil];
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [[NSNotificationCenter defaultCenter] postNotificationName:DGSearchTextFieldDidEndEditing object:nil];
}

- (void)searchFieldDidChange:(id)sender {
    if ([_searchField.text length] == 0) {
        _searchField.rightView.hidden = YES;
    } else {
        _searchField.rightView.hidden = NO;
    }
    if (peopleButton.selected) {
        if ([_searchField.text length] > 1) {
            tableView.hidden = NO;
            [searchPeopleTable getUsersByName:_searchField.text];
        } else {
            tableView.hidden = YES;
            [searchPeopleTable purge];
        }
    }

}

@end
