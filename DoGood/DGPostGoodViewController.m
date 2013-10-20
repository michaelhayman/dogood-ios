#import "DGPostGoodViewController.h"
#import "GoodOverviewCell.h"
#import "GoodShareCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodLocationViewController.h"
#import "DGTwitterManager.h"
#import "DGFacebookManager.h"
#import "DGEntityHandler.h"

#import <UIImage+Resize.h>
#import <MBProgressHUD.h>

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
    [self setupMenuTitle:@"Post Good"];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatedCategory:)
                                                 name:@"DGUserDidUpdateGoodCategory"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatedLocation:)
                                                 name:@"DGUserDidUpdateGoodLocation"
                                               object:nil];

    UINib *nib = [UINib nibWithNibName:@"GoodOverviewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"GoodOverviewCell"];
    UINib *shareNib = [UINib nibWithNibName:@"GoodShareCell" bundle:nil];
    [[self tableView] registerNib:shareNib forCellReuseIdentifier:@"GoodShareCell"];

    // UIFont *font = [UIFont boldSystemFontOfSize:17];
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
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(uploadAvatar:) name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(deleteAvatar) name:DGUserDidRemovePhotoNotification object:nil];

    // keyboard
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    self.tableView.bounces = NO;
    self.tableView.bouncesZoom = NO;
}

- (void)keyboardWillHide:(NSNotification *)notification {
    self.tableView.bounces = YES;
    self.tableView.bouncesZoom = YES;
}


- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidAddPhotoNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidRemovePhotoNotification object:nil];
       [super viewWillDisappear:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    DebugLog(@"good %@", self.good);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - UITableView data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 5;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == share) {
        // return 3;
        return 2;
    } else if (section == who) {
        return 0;
    } else {
        return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == overview) {
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
            cell.imageView.image = [UIImage imageNamed:@"CategoryIconOn.png"];
            cell.textLabel.text = self.good.category.name;
        } else {
            cell.textLabel.text = @"Add a category";
            cell.imageView.image = [UIImage imageNamed:@"CategoryIconOff.png"];
        }

        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == location) {
        static NSString *CellIdentifier = @"location";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (self.good.location_name) {
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOn.png"];
            cell.textLabel.text = self.good.location_name;
        } else {
            cell.textLabel.text = @"Add a location";
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOff.png"];
        }
        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == who) {
        static NSString *CellIdentifier = @"who";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
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
    if (indexPath.section == category) {
        DebugLog(@"good.category %@", self.good.category);
        if (self.good.category != nil) {
            DebugLog(@"shouldn't be nil");
            [categorySheet showInView:self.view];
        } else {
            DebugLog(@"should be nil");
            [self showCategoryChooser];
        }
        DebugLog(@"category");
    } else if (indexPath.section == location) {
        DebugLog(@"good.location %@", self.good.location_name);
        if (self.good.location_name != nil) {
            DebugLog(@"shouldn't be nil");
            [locationSheet showInView:self.view];
        } else {
            DebugLog(@"should be nil");
            [self showLocationChooser];
        }
        DebugLog(@"category");
    } else if (indexPath.section == who) {
        DebugLog(@"who");
    }
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

#pragma mark - UIActionSheets
- (void) showCategoryChooser {
    DebugLog(@"show categories");
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGPostGoodCategoryViewController *categoryController = [storyboard instantiateViewControllerWithIdentifier:@"PostGoodCategory"];

    [self.navigationController pushViewController:categoryController animated:YES];
}

- (void) showLocationChooser {
    DebugLog(@"show categories");
    UIStoryboard *storyboard;
    storyboard = [UIStoryboard storyboardWithName:@"Good" bundle:nil];
    DGPostGoodLocationViewController *locationController = [storyboard instantiateViewControllerWithIdentifier:@"PostGoodLocation"];

    [self.navigationController pushViewController:locationController animated:YES];
}

- (void)setUpActionSheets {
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

- (void)uploadAvatar:(NSNotification *)notification  {
    imageToUpload = [[notification userInfo] objectForKey:UIImagePickerControllerEditedImage];
    // self.good.image = [PFFile fileWithData:UIImagePNGRepresentation(imageToUpload)];
    self.good.image = imageToUpload;
    DebugLog(@"imagetoupload");
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    cell.image.image = imageToUpload;
}

- (void)deleteAvatar {
    imageToUpload = nil;
    DebugLog(@"remove");
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    cell.image.image = nil;
    self.good.image = nil;
    [self.tableView reloadData];
}

- (void)openPhotoSheet {
    [photos openPhotoSheet:self.good.image];
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == categorySheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == remove_button) {
                DebugLog(@"remove");
                self.good.category = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showCategoryChooser];
                DebugLog(@"select new");
            }
        }
        if (actionSheet == locationSheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == remove_button) {
                DebugLog(@"remove");
                self.good.location_name = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showLocationChooser];
                DebugLog(@"select new");
            }
        }
    } else {
        DebugLog(@"button index %d, %d", buttonIndex, actionSheet.cancelButtonIndex);
        // [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
    }
}

#pragma mark - Change data responses
- (void)receiveUpdatedCategory:(NSNotification *)notification {
    self.good.category = [[notification userInfo] valueForKey:@"category"];
    [self.good setValuesForCategory:self.good.category];
    [self.tableView reloadData];
}

- (void)receiveUpdatedLocation:(NSNotification *)notification {
    DebugLog(@"receiving");
    FSLocation *location = [[notification userInfo] valueForKey:@"location"];
    DebugLog(@"location %@ %@ %@", location.displayName, location.lat, location.imageURL);
    [self.good setValuesForLocation:location];
    DebugLog(@"location %@", self.good.location_image);
    [self.tableView reloadData];
}

#pragma mark - actions
- (IBAction)post:(id)sender {
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    self.good.caption = cell.description.text;

    UISwitch *twitter = (UISwitch *)[self.tableView viewWithTag:share_twitter_cell_tag];
    self.good.shareTwitter = twitter.on;
    DebugLog(@"sharin %d %d", twitter.on, self.good.shareTwitter);
    UISwitch *facebook = (UISwitch *)[self.tableView viewWithTag:share_facebook_cell_tag];
    self.good.shareFacebook = facebook.on;
    DebugLog(@"post good %@", self.good);
    DebugLog(@"location %@", self.good.location_image);
    self.good.entities = cell.entities;

    bool errors = YES;
    NSString *message;

    if ([self.good.caption isEqualToString:@""] || [self.good.caption isEqualToString:TEXTVIEW_TEXT]) {
        message = @"Make sure you fill in a caption for your good";
    } else {
        errors = NO;
    }

    if (!errors) {
        MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"Posting good...";

        NSMutableURLRequest *request = [[RKObjectManager sharedManager] multipartFormRequestWithObject:self.good method:RKRequestMethodPOST path:@"/goods.json" parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            if (self.good.image) {
                UIImage *resizedImage = [self.good.image resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 480) interpolationQuality:kCGInterpolationHigh];

                DebugLog(@"uiimage size %@", NSStringFromCGSize(resizedImage.size));
                [formData appendPartWithFileData:UIImagePNGRepresentation(resizedImage)
                                            name:@"good[evidence]"
                                        fileName:@"evidence.png"
                                        mimeType:@"image/png"];
            }
        }];

        RKObjectRequestOperation *operation = [[RKObjectManager sharedManager] objectRequestOperationWithRequest:request success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
            // post this notification about whether it was shared or not too
            [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidPostGood object:nil];

            if (self.good.shareTwitter) {
                DebugLog(@"post to twitter");
                [twitterManager postToTwitter:[NSString stringWithFormat:@"I did some good! %@", self.good.caption] andImage:self.good.image withSuccess:^(BOOL success, NSString *msg, ACAccount *account) {
                    [[DGUser currentUser] saveSocialID:[twitterManager getTwitterIDFromAccount:account] withType:@"twitter"];
                    DebugLog(@"%@", msg);
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
                params[@"link"] = @"http://www.dogoodapp.com/";
                params[@"name"] = @"Do Good, get a high score and earn rewards.";
                params[@"caption"] = self.good.caption;
                [facebookManager postToFacebook:params andImage:self.good.image withSuccess:^(BOOL success, NSString *msg, ACAccount *account) {
                    DebugLog(@"%@", msg);
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

            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            // Set custom view mode
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Completed";
            [hud hide:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [TSMessage showNotificationInViewController:self.navigationController
                                      title:nil
                                    subtitle:[error localizedDescription]
                                       type:TSMessageNotificationTypeError];
            [hud hide:YES];
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
