#import "DGPostGoodViewController.h"
#import "GoodOverviewCell.h"
#import "GoodShareCell.h"
#import "DGGood.h"
#import "DGNominee.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodLocationViewController.h"
#import "DGTwitterManager.h"
#import "DGFacebookManager.h"
#import "DGEntityHandler.h"
#import <ProgressHUD/ProgressHUD.h>
#import <UIImage+Resize.h>
#import "DGPhotoPickerViewController.h"

#define good_overview_cell_tag 69
#define share_do_good_cell_tag 501
#define share_facebook_cell_tag 502
#define share_twitter_cell_tag 503

@interface DGPostGoodViewController ()

@end

@implementation DGPostGoodViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    // [self setupMenuTitle:@"Post"];
    self.navigationItem.backBarButtonItem = [DGAppearance barButtonItemWithNoText];

    UINib *nib = [UINib nibWithNibName:@"GoodOverviewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"GoodOverviewCell"];
    UINib *shareNib = [UINib nibWithNibName:@"GoodShareCell" bundle:nil];
    [[self tableView] registerNib:shareNib forCellReuseIdentifier:@"GoodShareCell"];

    [postButton setTitleTextAttributes:FONT_BAR_BUTTON_ITEM_BOLD
                                     forState:UIControlStateNormal];

    [self setUpActionSheets];

    self.good = [DGGood new];
    self.good.user = [DGUser currentUser];
    facebookManager = [[DGFacebookManager alloc] initWithAppName:APP_NAME];
    twitterManager = [[DGTwitterManager alloc] initWithAppName:APP_NAME];

    // photos
    photos = [[DGPhotoPickerViewController alloc] init];
    photos.parent = self;
    photos.delegate = self;
    if (self.category) {
        self.navigationController.navigationBar.barTintColor = [self.category rgbColour];
        self.good.category = self.category;
    }
    [self setupNavigationBar];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if (self.category) {
        self.navigationController.navigationBar.barTintColor = [self.category rgbColour];
        self.good.category = self.category;
        self.navigationController.navigationBar.tintColor = [DGAppearance makeContrastingColorFromColor:[self.category rgbColour]];
    } else {
        self.navigationController.navigationBar.barTintColor = VIVID;
        self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    }
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.navigationController.navigationBar.barTintColor = VIVID;
}

- (void)setupNavigationBar {
    tabControl = [[UISegmentedControl alloc] initWithItems:[NSArray arrayWithObjects:@"Nominate", @"Ask for help", nil]];

    [tabControl setSelectedSegmentIndex:0];

    [tabControl sizeToFit];

    [tabControl addTarget:self action:@selector(chooseTab:) forControlEvents:UIControlEventValueChanged];

    [self setTableMode];

    self.navigationItem.titleView = tabControl;
}

- (IBAction)chooseTab:(id)sender {
    DebugLog(@"sup %d", tabControl.selectedSegmentIndex);
    [self setTableMode];
    [self.tableView reloadData];
}

- (void)setTableMode {
    if (tabControl.selectedSegmentIndex == 0) {
        self.good.done = [NSNumber numberWithBool:YES];
    } else {
        self.good.done = [NSNumber numberWithBool:NO];
    }

    GoodOverviewCell *cell = [self overviewCell];
    [cell setDoneMode:[self.good.done boolValue]];
}

-(void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.tableView.bounces = NO;
    self.tableView.bouncesZoom = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableView.bounces = YES;
    self.tableView.bouncesZoom = YES;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];

    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    [TSMessage dismissActiveNotification];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)dealloc {
}

#pragma mark - UITableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == share) {
        // return 3;
        return 2;
    } else if (section == nominee) {
        if ([self.good.done boolValue]) {
            return 1;
        } else {
            return 0;
        }
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return [self heightForSection:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return [self heightForSection:section];
}

- (CGFloat)heightForSection:(NSInteger)section {
    if (section == nominee && ![self.good.done boolValue]) {
        return 0.01f;
    } else {
        return 8;
    }
}

#define kNomineeCell @"nominee"

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == nominee) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:kNomineeCell];
        if (self.good.nominee) {
            cell.textLabel.text = self.good.nominee.full_name;
            if (self.good.nominee.avatarImage) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:cell.accessoryView.frame];
                imageView.image = self.good.nominee.avatarImage;
                cell.accessoryView = imageView;
            } else {
                cell.imageView.image = [UIImage imageNamed:@"PostNomineeOn"];
            }
        } else {
            cell.textLabel.text = @"Who did good?";
            cell.imageView.image = [UIImage imageNamed:@"PostNomineeOff"];
        }
        return cell;
    } else if (indexPath.section == overview) {
        GoodOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodOverviewCell"];
        // cell.description.delegate = self;
        cell.parent = self;
        [cell initEntityHandler];
        UITapGestureRecognizer* imageGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(openPhotoSheet)];
        [cell.image setUserInteractionEnabled:YES];
        [cell.image addGestureRecognizer:imageGesture];
        cell.tag = good_overview_cell_tag;
        return cell;
    } else if (indexPath.section == category) {
        static NSString *CellIdentifier = @"category";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (self.good.category) {
            cell.imageView.image = [UIImage imageNamed:@"CategoryIconOn"];
            cell.textLabel.text = self.good.category.name;
        } else {
            cell.textLabel.text = @"Add a category";
            cell.imageView.image = [UIImage imageNamed:@"CategoryIconOff"];
        }

        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == location) {
        static NSString *CellIdentifier = @"location";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (self.good.location_name) {
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOn"];
            cell.textLabel.text = self.good.location_name;
        } else {
            cell.textLabel.text = @"Where?";
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOff"];
        }
        // Configure the cell...
        
        return cell;
    } else {
        GoodShareCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodShareCell"];
        if (indexPath.row == 0) {
            cell.share.tag = share_facebook_cell_tag;
            [cell facebook];
            cell.facebookManager = facebookManager;
        } else {
            cell.share.tag = share_twitter_cell_tag;
            [cell twitter];
            cell.twitterManager = twitterManager;
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == overview) {
        return 102;
    }
    if (indexPath.section == share) {
        return 54;
    } else {
        return 44;
    }
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    GoodOverviewCell *cell = [self overviewCell];
    [cell.description resignFirstResponder];

    if (indexPath.section == nominee) {
        if (self.good.nominee != nil) {
            [nomineeSheet showInView:self.view];
        } else {
            [self showNomineeChooser];
        }
    } else if (indexPath.section == category) {
        if (self.good.category != nil) {
            [categorySheet showInView:self.view];
        } else {
            [self showCategoryChooser];
        }
    } else if (indexPath.section == location) {
        if (self.good.location_name != nil) {
            [locationSheet showInView:self.view];
        } else {
            [self showLocationChooser];
        }
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheets
- (void)showNomineeChooser {
    if (nomineeController == nil) {
        nomineeController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostGoodNominee"];
        nomineeController.postGoodDelegate = self;
    }
    [self.navigationController pushViewController:nomineeController animated:YES];
}

- (void)showCategoryChooser {
    DGPostGoodCategoryViewController *categoryController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostGoodCategory"];
    categoryController.delegate = self;

    [self.navigationController pushViewController:categoryController animated:YES];
}

- (void) showLocationChooser {
    DGPostGoodLocationViewController *locationController = [self.storyboard instantiateViewControllerWithIdentifier:@"PostGoodLocation"];
    locationController.delegate = self;

    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)setUpActionSheets {
    nomineeSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Remove nominee"
                                       otherButtonTitles:@"Select new nominee", nil];
    [nomineeSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    categorySheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Remove category"
                                       otherButtonTitles:@"Select new category", nil];
    [categorySheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];

    locationSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:@"Remove location"
                                       otherButtonTitles:@"Select new location", nil];
    [locationSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
}

- (void)openPhotoSheet {
    [photos openPhotoSheet:self.good.image];
}

- (GoodOverviewCell *)overviewCell {
    return (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == nomineeSheet) {
            if (buttonIndex == remove_button) {
                self.good.nominee = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showNomineeChooser];
            }
        }
        if (actionSheet == categorySheet) {
            if (buttonIndex == remove_button) {
                self.good.category = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showCategoryChooser];
            }
        }
        if (actionSheet == locationSheet) {
            if (buttonIndex == remove_button) {
                self.good.location_name = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showLocationChooser];
            }
        }
    }
}

#pragma mark - Change data responses
- (void)childViewController:(DGPostGoodNomineeSearchViewController *)viewController didChooseNominee:(DGNominee *)nominee {
    self.good.nominee = nominee;
    // [self.good setValuesForNominee:self.good.nominee];
    [self.tableView reloadData];
}

- (void)childViewController:(DGPostGoodCategoryViewController *)viewController didChooseCategory:(DGCategory *)category {
    self.good.category = category;
    [self.good setValuesForCategory:self.good.category];
    [self.tableView reloadData];
}

- (void)childViewController:(DGPostGoodLocationViewController *)viewController didChooseLocation:(FSLocation *)location {
    [self.good setValuesForLocation:location];
    [self.tableView reloadData];
}

- (void)childViewController:(DGPhotoPickerViewController* )viewController didChoosePhoto:(NSDictionary *)dictionary {
    imageToUpload = [dictionary objectForKey:UIImagePickerControllerEditedImage];
    self.good.image = imageToUpload;
    GoodOverviewCell *cell = [self overviewCell];
    cell.image.image = imageToUpload;
}

- (void)removePhoto {
    imageToUpload = nil;
    GoodOverviewCell *cell = [self overviewCell];
    cell.image.image = nil;
    self.good.image = nil;
    [self.tableView reloadData];
}

#pragma mark - actions
- (IBAction)post:(id)sender {
    GoodOverviewCell *cell = [self overviewCell];
    self.good.caption = cell.description.text;

    UISwitch *twitter = (UISwitch *)[self.tableView viewWithTag:share_twitter_cell_tag];
    self.good.shareTwitter = twitter.on;
    UISwitch *facebook = (UISwitch *)[self.tableView viewWithTag:share_facebook_cell_tag];
    self.good.shareFacebook = facebook.on;
    self.good.entities = cell.entities;

    bool errors = YES;
    NSString *message;

    if ([self.good.caption isEqualToString:@""]) {
        message = @"Make sure you fill in a caption for your good";
    } else {
        errors = NO;
    }

    if (!errors) {
        [cell.description resignFirstResponder];
        [ProgressHUD show:@"Posting good..."];

        NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:self.good method:RKRequestMethodPOST path:@"/goods.json" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (self.good.image) {
                UIImage *resizedImage = [self.good.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 480) interpolationQuality:kCGInterpolationHigh];

                [formData appendPartWithFileData:UIImagePNGRepresentation(resizedImage)
                                            name:@"good[evidence]"
                                        fileName:@"evidence.png"
                                        mimeType:@"image/png"];
            }
        }];

        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            // post this notification about whether it was shared or not too
            DGGood *postedGood = [mappingResult.array objectAtIndex:0];
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidPostGood object:nil];

            if (self.good.shareTwitter) {
                DebugLog(@"post to twitter");
                [twitterManager postToTwitter:[NSString stringWithFormat:@"I did some good! %@", self.good.caption] andImage:self.good.image withSuccess:^(BOOL success, NSString *msg, ACAccount *account) {
                    [[DGUser currentUser] saveSocialID:[twitterManager getTwitterIDFromAccount:account] withType:@"twitter"];
                } failure:^(NSError *error) {
                    DebugLog(@"error %@ %@", [error localizedRecoverySuggestion], [error localizedDescription]);
                }];
            } else {
                DebugLog(@"don't post to twitter");
            }

            if (self.good.shareFacebook) {
                DebugLog(@"sharing to fb");

                NSMutableDictionary *params = [NSMutableDictionary dictionary];
                params[@"message"] = @"I did some good!";
                params[@"link"] = @"http://dogood.springbox.ca/";
                params[@"name"] = @"Compete with me on Do Good! Get a high score and earn rewards.";
                params[@"caption"] = self.good.caption;
                params[@"picture"] = NSNullIfNil(postedGood.evidence);
                [facebookManager postToFacebook:params andImage:self.good.image withSuccess:^(BOOL success, NSString *msg, ACAccount *account) {
                    [facebookManager findFacebookIDForAccount:account withSuccess:^(BOOL success, NSString *facebookID) {
                        [[DGUser currentUser] saveSocialID:facebookID withType:@"facebook"];
                    } failure:^(NSError *findError) {
                        DebugLog(@"didn't find id");
                    }];
                } failure:^(NSError *error) {
                    DebugLog(@"error %@ %@", [error localizedRecoverySuggestion], [error localizedDescription]);
                }];
            } else {
                DebugLog(@"not sharing to fb");
            }

            [self.navigationController popViewControllerAnimated:YES];

            [ProgressHUD showSuccess:@"Good posted!"];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [TSMessage showNotificationInViewController:self.navigationController
                                      title:nil
                                    subtitle:[error localizedDescription]
                                       type:TSMessageNotificationTypeError];
            [ProgressHUD showError:nil];
        }];

        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    } else {
        [TSMessage showNotificationInViewController:self.navigationController
                                  title:nil
                                subtitle:NSLocalizedString(message, nil)
                                   type:TSMessageNotificationTypeError];
    }
}

@end
