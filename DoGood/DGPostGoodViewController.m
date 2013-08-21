#import "DGPostGoodViewController.h"
#import "GoodOverviewCell.h"
#import "GoodShareCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "FSLocation.h"
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodLocationViewController.h"
#import "ThirdParties.h"

#import <UIImage+Resize.h>
#import <MBProgressHUD.h>

@interface DGPostGoodViewController ()

@end

@implementation DGPostGoodViewController

#pragma mark - View lifecycle
- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Post Good";

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatedCategory:)
                                                 name:@"DGUserDidUpdateGoodCategory"
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveUpdatedLocation:)
                                                 name:@"DGUserDidUpdateGoodLocation"
                                               object:nil];

    // customize look
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.backgroundView = nil;
    self.tableView.opaque = NO;
    self.view.backgroundColor = [UIColor whiteColor];

    UINib *nib = [UINib nibWithNibName:@"GoodOverviewCell" bundle:nil];
    [[self tableView] registerNib:nib forCellReuseIdentifier:@"GoodOverviewCell"];
    UINib *shareNib = [UINib nibWithNibName:@"GoodShareCell" bundle:nil];
    [[self tableView] registerNib:shareNib forCellReuseIdentifier:@"GoodShareCell"];

    [self setUpActionSheets];

    self.good = [DGGood new];
    self.good.user = [DGUser currentUser];
    // self.good.category = [DGCategory object];
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

#define good_overview_cell_tag 69
#define share_do_good_cell_tag 501
#define share_facebook_cell_tag 502
#define share_twitter_cell_tag 503
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == overview) {
        GoodOverviewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"GoodOverviewCell"];
        cell.description.delegate = self;

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
            cell.textLabel.text = self.good.category.displayName;
        } else {
            cell.textLabel.text = @"Add a category";
            cell.imageView.image = [UIImage imageNamed:@"CategoryIconOff.png"];
        }

        // Configure the cell...
        
        return cell;
    } else if (indexPath.section == location) {
        static NSString *CellIdentifier = @"location";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        if (self.good.locationName) {
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOn.png"];
            cell.textLabel.text = self.good.locationName;
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
            cell.type.text = @"Share on Facebook";
            [cell facebook];
        } else {
            cell.share.tag = share_twitter_cell_tag;
            cell.type.text = @"Share on Twitter";
            [cell twitter];
        }
        return cell;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == overview) {
        return 102;
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
        DebugLog(@"good.location %@", self.good.locationName);
        if (self.good.locationName != nil) {
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

- (void)openPhotoSheet {
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    cell.image.highlighted = YES;
    NSString *destructiveButtonTitle;
    if (self.good.image) {
        destructiveButtonTitle = @"Remove photo";
    } else {
        destructiveButtonTitle = nil;
    }

    photoSheet = [[UIActionSheet alloc] initWithTitle:nil
                                                delegate:self
                                       cancelButtonTitle:@"Cancel"
                                  destructiveButtonTitle:destructiveButtonTitle
                                       otherButtonTitles:@"Add from camera", @"Add from camera roll", nil];
    [photoSheet setActionSheetStyle:UIActionSheetStyleBlackTranslucent];
    [photoSheet showInView:self.view];
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
                self.good.locationName = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == select_new_button) {
                [self showLocationChooser];
                DebugLog(@"select new");
            }
        }
        if (actionSheet == photoSheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == photoSheet.destructiveButtonIndex) {
                DebugLog(@"remove");
                GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
                cell.image.image = nil;
                self.good.image = nil;
                [self.tableView reloadData];
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex) {
                [self showCamera];
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex + 1) {
                [self showCameraRoll];
            }
        }
    } else {
        DebugLog(@"button index %d, %d", buttonIndex, actionSheet.cancelButtonIndex);
        // [actionSheet dismissWithClickedButtonIndex:actionSheet.cancelButtonIndex animated:YES];
    }
}

#pragma mark - Camera helpers
- (void)showCameraRoll {
    DebugLog(@"show camera roll");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showCamera {
    DebugLog(@"show camera");
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    imageToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];
    // self.good.image = [PFFile fileWithData:UIImagePNGRepresentation(imageToUpload)];
    self.good.image = imageToUpload;
    DebugLog(@"imagetoupload");
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    cell.image.image = imageToUpload;
}

#pragma mark - UITextFieldDelegate
- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    DebugLog(@"getting hit");
    if([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
        return NO;
    }
    return YES;
}

/*
- (BOOL)textFieldShouldReturn:(UITextView *)text {
    if([text.text isEqualToString:@"\n"]) {
        [text resignFirstResponder];
        return NO;
    }
    return YES;
}
*/

#pragma mark - Change data responses
- (void)receiveUpdatedCategory:(NSNotification *)notification {
    self.good.category = [[notification userInfo] valueForKey:@"category"];
    // replace with specific rows to reload
    [self.tableView reloadData];
}

- (void)receiveUpdatedLocation:(NSNotification *)notification {
    DebugLog(@"receiving");
    FSLocation *location = [[notification userInfo] valueForKey:@"location"];
    [self.good setValuesForLocation:location];
    [self.tableView reloadData];
}

#pragma mark - actions
- (IBAction)post:(id)sender {
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    self.good.caption = cell.description.text;

    // GoodShareCell *doGood = (GoodShareCell *)[self.tableView viewWithTag:share_do_good_cell_tag];
    // self.good.shareDoGood = doGood.share.on;
    // GoodShareCell *twitter = (GoodShareCell *)[self.tableView viewWithTag:share_twitter_cell_tag];
    // self.good.shareTwitter = twitter.share.on;
    UISwitch *twitter = (UISwitch *)[self.tableView viewWithTag:share_twitter_cell_tag];
    self.good.shareTwitter = twitter.on;
    DebugLog(@"sharin %d %d", twitter.on, self.good.shareTwitter);
    // GoodShareCell *facebook = (GoodShareCell *)[self.tableView viewWithTag:share_facebook_cell_tag];
    // self.good.shareFacebook = facebook.share.on;
    UISwitch *facebook = (UISwitch *)[self.tableView viewWithTag:share_facebook_cell_tag];
    self.good.shareFacebook = facebook.on;
    DebugLog(@"post good %@", self.good);

    bool errors = YES;
    NSString *message;

    if ([self.good.caption isEqualToString:@""]) {
        message = @"Make sure you fill in a caption for your good";
    } else {
        errors = NO;
    }

    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"Posting good...";

    if (!errors) {
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
            [TSMessage showNotificationInViewController:self.navigationController.parentViewController
                                      withTitle:NSLocalizedString(@"Saved!", nil)
                                    withMessage:NSLocalizedString(@"You made some points!", nil)
                                       withType:TSMessageNotificationTypeSuccess];

            if (self.good.shareTwitter) {
                DebugLog(@"post to twitter");
                [ThirdParties postToTwitter:[NSString stringWithFormat:@"I did some good! %@", self.good.caption]];
            } else {
                DebugLog(@"don't post to twitter");
            }

            if (self.good.shareFacebook) {
                [ThirdParties postToFacebook:self.good.caption andImage:self.good.image];
            }
            [self.navigationController popViewControllerAnimated:YES];

            hud.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"37x-Checkmark.png"]];
            // Set custom view mode
            hud.mode = MBProgressHUDModeCustomView;
            hud.labelText = @"Completed";
            [hud hide:YES];
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [TSMessage showNotificationInViewController:self
                                      withTitle:nil
                                    withMessage:[error localizedDescription]
                                       withType:TSMessageNotificationTypeError];
            [hud hide:YES];
        }];

        [[RKObjectManager sharedManager] enqueueObjectRequestOperation:operation]; // NOTE: Must be enqueued rather than started
    } else {
        [TSMessage showNotificationInViewController:self
                                  withTitle:nil
                                withMessage:NSLocalizedString(message, nil)
                                   withType:TSMessageNotificationTypeError];
    }
}

#pragma mark - Sharing methods
- (void)checkDoGood {
    DebugLog(@"do good");
}

- (void)checkTwitter {
    DebugLog(@"twitter");
}

- (void)checkFacebook {
    // only activate when selected...
    // DGUser *user = [DGUser currentUser];
}

@end
