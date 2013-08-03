#import "DGPostGoodViewController.h"
#import "GoodOverviewCell.h"
#import "GoodShareCell.h"
#import "DGGood.h"
#import "DGCategory.h"
#import "DGLocation.h"
#import "DGPostGoodCategoryViewController.h"
#import "DGPostGoodLocationViewController.h"

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

    self.good = [DGGood object];
    self.good.user = [PFUser currentUser];
    // self.good.category = [DGCategory object];
}

- (void)viewWillAppear:(BOOL)animated {
    DebugLog(@"good %@", self.good);
    DebugLog(@"location %@", self.good.location);
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
        if (self.good.location) {
            cell.imageView.image = [UIImage imageNamed:@"LocationIconOn.png"];
            cell.textLabel.text = self.good.location.displayName;
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
            cell.tag = share_facebook_cell_tag;
            cell.type.text = @"Share on Facebook";
            [cell facebook];
        } else {
            cell.tag = share_twitter_cell_tag;
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
        DebugLog(@"good.location %@", self.good.location);
        if (self.good.location != nil) {
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
                self.good.location = nil;
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
    UIImagePickerController *pickerC = [[UIImagePickerController alloc] init];
    pickerC.delegate = self;
    pickerC.allowsEditing = YES;
    [self presentViewController:pickerC animated:YES completion:nil];
}

- (void)showCamera {
    DebugLog(@"show camera");
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [self dismissViewControllerAnimated:YES completion:nil];
    imageToUpload = [info objectForKey:UIImagePickerControllerOriginalImage];
    self.good.image = [PFFile fileWithData:UIImagePNGRepresentation(imageToUpload)];
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
    self.good.location = [[notification userInfo] valueForKey:@"location"];
    [self.tableView reloadData];
}

#pragma mark - actions
- (IBAction)post:(id)sender {
    GoodOverviewCell *cell = (GoodOverviewCell *)[self.tableView viewWithTag:good_overview_cell_tag];
    self.good.caption = cell.description.text;
    GoodShareCell *doGood = (GoodShareCell *)[self.tableView viewWithTag:share_do_good_cell_tag];
    self.good.shareDoGood = doGood.share.on;
    GoodShareCell *twitter = (GoodShareCell *)[self.tableView viewWithTag:share_twitter_cell_tag];
    self.good.shareTwitter = twitter.share.on;
    GoodShareCell *facebook = (GoodShareCell *)[self.tableView viewWithTag:share_facebook_cell_tag];
    self.good.shareFacebook = facebook.share.on;
    DebugLog(@"post good %@ to Parse here", self.good);

    bool errors = YES;
    NSString *message;

    if ([self.good.caption isEqualToString:@""]) {
        message = @"Make sure you fill in a caption for your good";
    } else {
        errors = NO;
    }

    if (!errors) {
        // [self.good saveInBackground];
        [self.good saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (!succeeded) {
                [TSMessage showNotificationInViewController:self
                                          withTitle:NSLocalizedString(@"Couldn't save", nil)
                                        withMessage:NSLocalizedString([error description], nil)
                                           withType:TSMessageNotificationTypeError];

                DebugLog(@"error %@", [error description]);
                return;
            }
            [TSMessage showNotificationInViewController:self.navigationController.parentViewController
                                      withTitle:NSLocalizedString(@"Saved!", nil)
                                    withMessage:NSLocalizedString(@"You made some points!", nil)
                                       withType:TSMessageNotificationTypeSuccess];

            if (self.good.shareTwitter) {
                [self postToTwitter:[NSString stringWithFormat:@"I did some good! %@", self.good.caption]];
            }

            if (self.good.shareFacebook) {
                [self postToFacebook:self.good.caption andImage:self.good.image];
            }

            [self.navigationController popViewControllerAnimated:YES];
        }];
     } else {
        [TSMessage showNotificationInViewController:self
                                  withTitle:NSLocalizedString(@"Couldn't save", nil)
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
    PFUser *user = [PFUser currentUser];
    if (![PFFacebookUtils isLinkedWithUser:user]) {
        [PFFacebookUtils linkUser:user permissions:nil block:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                DebugLog(@"Woohoo, user logged in with Facebook!");
                DebugLog(@"Set the Facebook thing to on");
            } else {
                DebugLog(@"Set the facebook thing to off again %@", [error description]);
            }
        }];
    } else {
        DebugLog(@"user already linked");
    }
}

- (void)postToFacebook:(NSString *)status andImage:(PFFile *)image {
    DebugLog(@"image URL %@", image.url);
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"message"] = @"I did some good!";
    params[@"link"] = @"http://www.dogoodapp.com/";
    params[@"name"] = @"Do Good, get a high score and earn rewards.";
    params[@"caption"] = status;
    /*
    if (imageToUpload) {
        [params setObject:UIImagePNGRepresentation(imageToUpload) forKey:@"picture"];
    }
    */
    if (image.url) {
        params[@"picture"] = image.url;
        params[@"icon"] = image.url;
    }

    [FBRequestConnection startWithGraphPath:@"me/feed" parameters:params HTTPMethod:@"POST" completionHandler:
     ^(FBRequestConnection *connection, id result, NSError *error) {
         if (!error) {
             DebugLog(@"%@", [NSString stringWithFormat: @"Posted action, id: %@", result[@"id"]]);
         } else {
             DebugLog(@"error! %@", [error description]);
         }
     }];
}

- (void)postToTwitter:(NSString *)status {
    // Construct the parameters string. The value of "status" is percent-escaped.
    NSString *bodyString = [NSString stringWithFormat:@"status=%@", [status stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];

    // Explicitly percent-escape the '!' character.
    bodyString = [bodyString stringByReplacingOccurrencesOfString:@"!" withString:@"%21"];

    NSURL *url = [NSURL URLWithString:@"https://api.twitter.com/1.1/statuses/update.json"];
    NSMutableURLRequest *tweetRequest = [NSMutableURLRequest requestWithURL:url];
    tweetRequest.HTTPMethod = @"POST";
    tweetRequest.HTTPBody = [bodyString dataUsingEncoding:NSUTF8StringEncoding];

    [[PFTwitterUtils twitter] signRequest:tweetRequest];

    NSURLResponse *response = nil;
    NSError *error = nil;

    // Post status synchronously.
    NSData *data = [NSURLConnection sendSynchronousRequest:tweetRequest
                                         returningResponse:&response
                                                     error:&error];

    // Handle response.
    if (!error) {
        NSLog(@"Response: %@", [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding]);
    } else {
        NSLog(@"Error: %@", error);
    }
}

@end
