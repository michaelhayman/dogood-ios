#import "DGUserSearchAddressBookViewController.h"
#import <AddressBook/AddressBook.h>
#import "UserCell.h"

@implementation DGUserSearchAddressBookViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Search Address Book";
    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"UserCell"];

    tableView.delegate = self;
    tableView.dataSource = self;

}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    DebugLog(@"notif here");
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(displayAddressBookView:) name:DGUserDidCheckIfAddressBookIsConnected object:nil];
    [self showAddressBook];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidCheckIfAddressBookIsConnected object:nil];
}

#pragma mark - Search Networks method overrides
- (void)showAuthorized {
    [super showAuthorized];
}

- (void)showUnauthorized {
    [super showUnauthorized];
    unauthorizedBackground.image = [UIImage imageNamed:@"AddressBookWatermark"];
    [authorizeButton setTitle:@"Search Address Book Contacts" forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"AddressBookButton"] forState:UIControlStateNormal];
    [authorizeButton setBackgroundImage:[UIImage imageNamed:@"AddressBookButtonTap"] forState:UIControlStateHighlighted];

    [authorizeButton addTarget:self action:@selector(getAccessToContacts:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark - Contacts
- (void)showAddressBook {
    contentDescription.text = @"Find Friends from your Address Book";
    [self checkContactsAccess];
}

- (void)checkContactsAccess {
    DebugLog(@"check contacts access");
    // ABAddressBookRef addressBookRef = ABAddressBookCreateWithOptions(NULL, NULL);

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    if (ABAddressBookGetAuthorizationStatus() == kABAuthorizationStatusAuthorized) {
        [dictionary setObject:[NSNumber numberWithBool:YES] forKey:@"connected"];
    }
    else {
        [dictionary setObject:[NSNumber numberWithBool:NO] forKey:@"connected"];
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidCheckIfAddressBookIsConnected object:nil userInfo:dictionary];
}

- (void)displayAddressBookView:(NSNotification *)notification {
    NSNumber* connected = [[notification userInfo] objectForKey:@"connected"];
    if ([connected boolValue]) {
        DebugLog(@"show external search autho");
        [self performSelectorOnMainThread:@selector(getAccessToContacts:) withObject:nil waitUntilDone:NO];
    } else {
        [self performSelectorOnMainThread:@selector(showUnauthorized) withObject:nil waitUntilDone:NO];
        DebugLog(@"display not available message");
    }
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

- (void)findEmailsFromAddressBook {
    ABAddressBookRef allPeople = ABAddressBookCreateWithOptions(NULL, NULL);
    CFArrayRef allContacts = ABAddressBookCopyArrayOfAllPeople(allPeople);
    CFIndex numberOfContacts  = ABAddressBookGetPersonCount(allPeople);


    NSMutableArray *emails = [[NSMutableArray alloc] init];

    for(int i = 0; i < numberOfContacts; i++){
        NSString* email = @"";

        ABRecordRef aPerson = CFArrayGetValueAtIndex(allContacts, i);
        ABMultiValueRef emailProperty = ABRecordCopyValue(aPerson, kABPersonEmailProperty);

        NSArray *emailArray = (__bridge_transfer NSArray *)ABMultiValueCopyArrayOfAllValues(emailProperty);

        if ([emailArray count] > 0) {
            if ([emailArray count] > 1) {
                for (int i = 0; i < [emailArray count]; i++) {
                    email = [email stringByAppendingString:[NSString stringWithFormat:@"%@\n", [emailArray objectAtIndex:i]]];
                }
            } else {
                email = [NSString stringWithFormat:@"%@", [emailArray objectAtIndex:0]];
            }
        }

        if (emailProperty) {
            CFRelease(emailProperty);
        }
        if (aPerson) {
            CFRelease(aPerson);
        }

        [emails addObjectsFromArray:emailArray];
    }

    CFRelease(allContacts);

    NSString *path = [NSString stringWithFormat:@"/users/search_by_emails"];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
    [dictionary setObject:emails forKey:@"emails"];

    [[RKObjectManager sharedManager] getObjectsAtPath:path parameters:dictionary success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        users = [[NSArray alloc] initWithArray:mappingResult.array];
        if ([users count] > 0) {
            [self performSelectorOnMainThread:@selector(showAuthorized) withObject:nil waitUntilDone:NO];
            [tableView performSelectorOnMainThread:@selector(reloadData) withObject:nil waitUntilDone:NO];
        } else {
            [self performSelectorOnMainThread:@selector(showNoUsersFoundMessage) withObject:nil waitUntilDone:NO];
        }
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        [self performSelectorOnMainThread:@selector(showUnauthorized) withObject:nil waitUntilDone:NO];
    }];
}

- (void)showNoUsersFoundMessage {
    [self showUnauthorized];
    [authorizeButton setTitle:@"Try again" forState:UIControlStateNormal];
    noUsersLabel.hidden = NO;
    noUsersLabel.text = @"No address book friends found";
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString * reuseIdentifier = @"UserCell";
    UserCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
    // NSArray *users;
    DGUser *user = users[indexPath.row];
    cell.user = user;
    [cell setValues];
    cell.navigationController = self.navigationController;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [users count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark - UIAlertViewDelegate methods
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    [alertView dismissWithClickedButtonIndex:buttonIndex animated:YES];
}

@end
