@interface DGSignUpViewController : UIViewController <UITextFieldDelegate> {
    UITextField *activeField;
    IBOutlet UITableView *tableView;
}

@end

typedef enum {
    signUpOverview,
    details,
    signUpNumRows
} SignUpRowType;

typedef enum {
    email,
    name,
    phone,
    signUpDetailsNumRows
} SignUpDetailsRowType;
