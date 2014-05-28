@interface DGSignUpDetailsViewController : DGViewController <UITextFieldDelegate> {
    UITextField *activeField;
    __weak IBOutlet UIImageView *avatar;
    __weak IBOutlet UIImageView *avatarOverlay;
    __weak IBOutlet UITableView *tableView;
}

@property (retain, nonatomic) DGUser* user;

@end

typedef enum {
    email,
    password,
    phone,
    signUpDetailsNumRows
} SignUpDetailsRowType;