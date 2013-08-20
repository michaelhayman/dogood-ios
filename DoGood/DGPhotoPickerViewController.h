@interface DGPhotoPickerViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UITapGestureRecognizer *dismissTap;

    UIImage *imageToUpload;
    UIImage *resizedImage;
    
    UIActionSheet *photoSheet;
}
@property (nonatomic, retain) UIViewController *parent;
@property bool hasImage;

- (void)openPhotoSheet:(UIImage *)image;

@end
