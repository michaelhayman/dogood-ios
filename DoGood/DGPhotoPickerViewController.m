#import "DGPhotoPickerViewController.h"
#import <UIImage+Resize.h>
#import "DGImageEditor.h"

@interface DGPhotoPickerViewController ()

@property(nonatomic,strong) DGImageEditor *imageEditor;

@end

@implementation DGPhotoPickerViewController

#pragma mark - View lifecycle
- (id)init {
    self = [super init];
    if (self) {
        UIOffset backButtonTextOffset = UIOffsetMake(0, -60);
        [[UIBarButtonItem appearanceWhenContainedIn:[UIImagePickerController class], nil] setBackButtonTitlePositionAdjustment:backButtonTextOffset
                                                             forBarMetrics:UIBarMetricsDefault];

        self.imageEditor = [[DGImageEditor alloc] initWithNibName:@"DGImageEditor" bundle:nil];
        self.imageEditor.checkBounds = YES;
        self.imageEditor.rotateEnabled = YES;

        __weak typeof(self) weakSelf = self;
        self.imageEditor.doneCallback = ^(UIImage *editedImage, BOOL canceled) {
            typeof(self) strongSelf = weakSelf;
            if(!canceled) {
                NSMutableDictionary *dictionary = [NSMutableDictionary dictionary];
                [dictionary setObject:editedImage forKey:UIImagePickerControllerEditedImage];

                if ([strongSelf.delegate respondsToSelector:@selector(childViewController:didChoosePhoto:)]) {
                    [strongSelf.delegate childViewController:strongSelf didChoosePhoto:dictionary];
                }
            }
            [strongSelf.parent dismissViewControllerAnimated:YES completion:nil];
        };
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

// work around default UIImagePickerController wrong-coloured status bar
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
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
    if (iPad) {
        [photoSheet showFromRect:self.initiatorView.frame inView:self.parent.view animated:YES];
    } else {
        [photoSheet showInView:_parent.view];
    }
}

#define remove_button 0
#define select_new_button 1
- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex != actionSheet.cancelButtonIndex) {
        if (actionSheet == photoSheet) {
            if (buttonIndex == photoSheet.destructiveButtonIndex) {
                if ([self.delegate respondsToSelector:@selector(removePhoto)]) {
                    [self.delegate removePhoto];
                }
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex) {
                [self showCamera];
            } else if (buttonIndex == photoSheet.firstOtherButtonIndex + 1) {
                [self showCameraRoll];
            }
        }
    }
}

- (void)showCameraRoll {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.delegate = self;
    imagePicker.navigationBar.barTintColor = VIVID;
    imagePicker.navigationItem.backBarButtonItem = [DGAppearance barButtonItemWithNoText];
    [_parent presentViewController:imagePicker animated:YES completion:nil];
}

- (void)showCamera {
    if ([UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.delegate = self;
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [_parent presentViewController:imagePicker animated:YES completion:nil];
    } else {
        DebugLog(@"Camera not available.");
    }
}

#pragma mark - UIImagePickerController delegate methods
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *image =  [info objectForKey:UIImagePickerControllerOriginalImage];

    // UIImage *scaledImage = [UIImage imageWithCGImage:[image CGImage] scale:(image.scale * 2.0) orientation:(image.imageOrientation)];
    // self.imageEditor.sourceImage = scaledImage;
    self.imageEditor.sourceImage = image;
    [self.imageEditor reset:NO];

    [picker pushViewController:self.imageEditor animated:YES];
    [picker setNavigationBarHidden:YES animated:NO];
}

@end
