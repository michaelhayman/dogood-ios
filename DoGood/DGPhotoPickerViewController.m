#import "DGPhotoPickerViewController.h"
#import <UIImage+Resize.h>
#import <MBProgressHUD.h>

/* 
 send NSNotifications:
 - did delete image
 - did select image
 
 then decide what to do
 remove NSNotificationObservers in willDisappear.  Can also remove them specifically.
 */

@interface DGPhotoPickerViewController ()

@end

@implementation DGPhotoPickerViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
}

#pragma mark - Camera helpers
- (void)openPhotoSheet:(UIImage *)image {
    NSString *destructiveButtonTitle;
    // this wont work, unless i set the image some other time... in profile get
    if (image) {
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
    photoSheet.delegate = self;
    [photoSheet showInView:_parent.view];
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == photoSheet) {
            DebugLog(@"button index %d", buttonIndex);
            if (buttonIndex == photoSheet.destructiveButtonIndex) {
                DebugLog(@"remove");
                [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidRemovePhotoNotification object:nil];
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

- (void)showCameraRoll {
    DebugLog(@"Show camera roll.");
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.allowsEditing = YES;
    [_parent presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        DebugLog(@"Show camera.");
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.allowsEditing = YES;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_parent presentViewController:imagePicker animated:YES completion:nil];
    } else {
        DebugLog(@"Camera not available.");
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [_parent dismissViewControllerAnimated:YES completion:nil];
    imageToUpload = [info objectForKey:UIImagePickerControllerEditedImage];
    resizedImage = [imageToUpload resizedImageWithContentMode:UIViewContentModeScaleAspectFit bounds:CGSizeMake(640, 480) interpolationQuality:kCGInterpolationMedium];

    NSMutableDictionary *dictionary = [NSMutableDictionary dictionaryWithDictionary:info];
    [dictionary setObject:resizedImage forKey:UIImagePickerControllerEditedImage];
    [[NSNotificationCenter defaultCenter] postNotificationName:DGUserDidAddPhotoNotification object:nil userInfo:dictionary];
}

@end
