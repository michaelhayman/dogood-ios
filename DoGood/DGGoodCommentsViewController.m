#import "DGGoodCommentsViewController.h"
#import "DGGood.h"
#import "DGComment.h"
#import "CommentCell.h"

@interface DGGoodCommentsViewController ()

@end

@implementation DGGoodCommentsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Comments";
    DebugLog(@"comments good %@", self.comment.good);
    UINib *nib = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"CommentCell"];
    comments = [[NSMutableArray alloc] init];
    [self fetchComments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)viewWillDisappear:(BOOL)animated {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    tableView.transform = CGAffineTransformMakeRotation(-M_PI);

    [self setupKeyboardBehaviour];
}

#pragma mark - Comment retrieval
- (void)fetchComments {
    DebugLog(@"refresh comments");

    [comments removeAllObjects];
    [tableView reloadData];
}

#pragma mark - Comment posting
- (IBAction)postComment:(id)sender {
    DebugLog(@"this part is fine.");
    DebugLog(@"this is fine %@", self.comment.body);
    DGComment *newComment = [DGComment new];
    newComment.body = commentInputField.text;
    newComment.good = self.good;
    newComment.user = [DGUser currentUser];
    bool succeeded = YES;
    NSError *error;

    if (!succeeded) {
        [TSMessage showNotificationInViewController:self
                                  withTitle:NSLocalizedString(@"Couldn't save", nil)
                                withMessage:NSLocalizedString([error description], nil)
                                   withType:TSMessageNotificationTypeError];

        DebugLog(@"error %@", [error description]);
        return;
    }

    [commentInputView resignFirstResponder];
    UITextField *commentText = (UITextField *)sender;
    commentText.text = @"";
    [TSMessage showNotificationInViewController:self
                              withTitle:NSLocalizedString(@"Saved!", nil)
                            withMessage:NSLocalizedString(@"Your comment was posted!", nil)
                               withType:TSMessageNotificationTypeSuccess];
    [self fetchComments];
}


#pragma mark - Keyboard management
- (void)setupKeyboardBehaviour {
    if (self.makeComment) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.0];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];

        [commentInputField becomeFirstResponder];

        [UIView commitAnimations];
    }

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    NSTimeInterval animationDuration;
    UIViewAnimationCurve animationCurve;
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    [[[notification userInfo] objectForKey:UIKeyboardAnimationDurationUserInfoKey] getValue:&animationDuration];
    [[[notification userInfo] objectForKey:UIKeyboardAnimationCurveUserInfoKey] getValue:&animationCurve];

    if (self.makeComment) {
        animationDuration = 0.0;
        animationCurve = 0.0;
        self.makeComment = NO;
    } else {
        DebugLog(@"bug off");
    }

    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    commentFieldBottom.constant = keyboardSize.height;
    tableViewBottom.constant = tableViewBottom.constant + keyboardSize.height;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    commentFieldBottom.constant = 0;
    tableViewBottom.constant = 44;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - UITextField delegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    if (![textField.text isEqualToString:@""]) {
        [self postComment:textField];
    }
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    int length = commentInputField.text.length - range.length + string.length;

    if (length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
    return YES;
}

#pragma mark - UITableView delegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    DGComment * comment = comments[indexPath.row];
    cell.user.text = comment.user.username;
    cell.comment.text = comment.body;
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 44;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    return [comments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    // This will create a "invisible" footer
    return 0.01f;
}

@end
