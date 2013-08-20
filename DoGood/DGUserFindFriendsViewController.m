#import "DGUserFindFriendsViewController.h"
#import "DGUserSearchViewController.h"
#import <AddressBook/AddressBook.h>
#import "UserCell.h"
#import "DGUserInvitesViewController.h"

@interface DGUserFindFriendsViewController () <
    UINavigationControllerDelegate>
@end

@implementation DGUserFindFriendsViewController

- (void)viewDidLoad {
    self.title = @"Find friends";

    // tabs
    tabs.segmentedControlStyle = 7;
    [tabs addTarget:self
                         action:@selector(pickTab:)
               forControlEvents:UIControlEventValueChanged];
    tabs.selectedSegmentIndex = 0;
    tabs.tintColor = [UIColor blackColor];
    
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];
    tableView.tableHeaderView = tableHeader;
    tabs.selectedSegmentIndex = 0;
    [tabs sendActionsForControlEvents:UIControlEventValueChanged];

    invites = [[DGUserInvitesViewController alloc] init];
    invites.parent = self;
    // show table by default
    // [self showAddressBook];
    // Request authorization to Address Book
}

- (IBAction)getAccessToContacts:(id)sender {
   ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusNotDetermined) {
        ABAddressBookRequestAccessWithCompletion(addressBookRef, ^(bool granted, CFErrorRef error) {
            if (granted) {
                [self findEmailsFromAddressBook];
                DebugLog(@"can add contacts not determined");
            } else {
                DebugLog(@"can't add contacts");
                [self promptForAddressBookAccess];
            }
            // First time access has been granted, add the contact
        });
    }
    else if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        // The user has previously given access, add the contact
        DebugLog(@"can add contacts determined");
        [self findEmailsFromAddressBook];
    }
    else {
        [self promptForAddressBookAccess];
        // The user has previously denied access
        // Send an alert telling user to change privacy setting in settings app
    }
}

- (void)promptForAddressBookAccess {
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:nil message:@"Enable access to Contacts in Settings > Privacy." delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = 59;
    alert.delegate = self;
    [alert show];
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

#pragma mark - Tabs
- (IBAction)pickTab:(id)sender {
    NSString *choice = [tabs titleForSegmentAtIndex:[tabs selectedSegmentIndex]];
    if ([choice isEqualToString:@"@"]) {
        DebugLog(@"@");
        [self showAddressBook];
    }
    if ([choice isEqualToString:@"T"]) {
        DebugLog(@"T");
        [self showTwitter];
    }
    if ([choice isEqualToString:@"S"]) {
        [self showInternalSearchOptions];
        DebugLog(@"S");
    }
}

- (void)showInternalSearch {
    tableView.hidden = YES;
    internalSearch.hidden = NO;
}

- (void)showExternalSearch {
    tableView.hidden = NO;
    internalSearch.hidden = YES;
}

- (void)showAddressBook {
    contentDescription.text = @"Find Friends from your address book";
    [self showExternalSearch];
    [self getAccessToContacts:nil];
    // [self findEmailsFromAddressBook];
}

- (void)showTwitter {
    contentDescription.text = @"Find Twitter friends on Do Good";
    [self showExternalSearch];
    [self findEmailsFromTwitter];
}

- (void)showInternalSearchOptions {
    [self showInternalSearch];
}

- (void)findEmailsFromTwitter {
    DebugLog(@"find emails from twitter");
    users = [[NSArray alloc] init];
    [tableView reloadData];
}

- (IBAction)searchForPeople:(id)sender {
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Users" bundle:nil];
    DGUserFindFriendsViewController *controller = [storyboard instantiateViewControllerWithIdentifier:@"UserSearch"];
    [self.navigationController pushViewController:controller animated:YES];
}

- (IBAction)inviteViaText:(id)sender {
    [invites inviteViaText:nil];
}

- (IBAction)inviteViaEmail:(id)sender {
    [invites inviteViaEmail:nil];
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    DGUser *user = users[indexPath.row];
    cell.user = user;
    DebugLog(@"user %@", user);
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [users count];
    /*
    if (section == 0) {
        return [users count];
    } else if (section == 1) {
        if (addressBookAccess) {
            return 0;
        } else {
            return 1;
        }
    }
    */
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - ABAddressBook methods
- (void)findEmailsFromAddressBook {
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);

    DebugLog(@"numberOfContacts: %ld",numberOfContacts);

    NSMutableArray *emails = [[NSMutableArray alloc] init];

    for(int i = 0; i < numberOfContacts; i++){
        NSString* email = @"";

        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);

        NSArray *emailArray = (__bridge NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);

        if ([emailArray count] > 0) {
            if ([emailArray count] > 1) {
                for (int i = 0; i < [emailArray count]; i++) {
                    email = [email stringByAppendingString:[NSString stringWithFormat:@"%@\n", [emailArray objectAtIndex:i]]];
                }
            }else {
                email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
            }
        }

        DebugLog(@"EMAIL: %@",email);
        DebugLog(@"\n");
        [emails addObjectsFromArray:emailArray];
    }

    NSString *path = [NSString stringWithFormat:@"/users/search_by_emails"];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:emails forKey:@"emails"];

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:dictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        users = [[NSArray alloc] initWithArray:mappingResult.array];
        DebugLog(@"users %@", users);
        [tableView reloadData];
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
}

@end
