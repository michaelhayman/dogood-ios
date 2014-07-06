@protocol DGPhotoPickerViewControllerDelegate;

@interface DGPhotoPickerViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIActionSheetDelegate, UIAlertViewDelegate> {
    UITapGestureRecognizer *dismissTap;

    UIImage *imageToUpload;
    UIImage *resizedImage;
    
    UIActionSheet *photoSheet;
}

@property (nonatomic, weak) UIView *initiatorView;
@property (nonatomic, weak) UIViewController *parent;
@property bool hasImage;
@property (nonatomic, weak) id<DGPhotoPickerViewControllerDelegate> delegate;

- (void)openPhotoSheet:(UIImage *)image;

@end

@protocol DGPhotoPickerViewControllerDelegate <NSObject>

- (void)childViewController:(DGPhotoPickerViewController* )viewController didChoosePhoto:(NSDictionary *)dictionary;
- (void)removePhoto;

@end
