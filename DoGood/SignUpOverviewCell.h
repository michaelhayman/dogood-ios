@interface SignUpOverviewCell : UITableViewCell <UITextViewDelegate> {
}
@property (weak, nonatomic) IBOutlet UITextField *username;
@property (weak, nonatomic) IBOutlet UITextField *password;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UIImageView *backgroundImage;

- (UIImage *)defaultImage;

@end
