#import "DGGoodCommentsViewController.h"
#import "DGGood.h"
#import "GoodCell.h"
#import "DGComment.h"
#import "CommentCell.h"
#import "DGEntity.h"
#import "DGTextFieldSearchPeopleTableViewController.h"
#import "DGAppearance.h"
#import "NoResultsCell.h"

#import "DGEntityHandler.h"

@interface DGGoodCommentsViewController ()

@end

#define DEGREES_TO_RADIANS(x) (M_PI * x / 180.0)

@implementation DGGoodCommentsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupMenuTitle:@"Comments"];
    sendButton.enabled = NO;

    // comments list
    UINib *nib = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"CommentCell"];
    UINib *noResultsNib = [UINib nibWithNibName:@"NoResultsCell" bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:@"NoResultsCell"];
    comments = [[NSMutableArray alloc] init];

    tableView.hidden = YES;
    tableView.tableFooterView = [[UIView alloc] init];

    loadingView = [DGAppearance createLoadingViewCenteredOn:tableView];
    [self.view addSubview:loadingView];

    characterLimit = 120;
    entities = [[NSMutableArray alloc] init];
    commentInputField.allowsEditingTextAttributes = NO;
    entityHandler = [[DGEntityHandler alloc] initWithTextView:commentInputField andEntities:entities inController:self withType:@"Comment" reverseScroll:YES tableOffset:0 secondTableOffset:44];

    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [self setupKeyboardBehaviour];
    [self fetchComments];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [TSMessage dismissActiveNotification];
    // [commentInputField resignFirstResponder];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

// TODO: not sure why this is in will appear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupKeyboardBehaviour];
}

#pragma mark - Comment retrieval ----------
- (void)fetchComments {
    NSDictionary *params = [NSDictionary dictionaryWithObject:self.good.goodID forKey:@"good_id"];
    loadingView.hidden = NO;

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/comments.json" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [comments removeAllObjects];
        [comments addObjectsFromArray:mappingResult.array];
        loadingStatus = @"No comments posted yet";

        tableView.hidden = NO;
        loadingView.hidden = YES;
        [tableView reloadData];
        DebugLog(@"reloading data");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        loadingStatus = @"Couldn't connect";

        tableView.hidden = NO;
        loadingView.hidden = YES;
        DebugLog(@"Operation failed with error: %@", error);
        [tableView reloadData];
    }];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
   if ([comments count] == 0) {
        tableView.transform = CGAffineTransformMakeRotation(M_PI);
        static NSString * reuseIdentifier = @"NoResultsCell";
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        cell.explanation.text = loadingStatus;
        cell.transform = CGAffineTransformMakeRotation(-M_PI);
        return cell;
    }
    tableView.transform = CGAffineTransformMakeRotation(-M_PI);

    CommentCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    DGComment * comment = comments[indexPath.row];
    cell.comment = comment;
    cell.navigationController = self.navigationController;
    [cell setValues];
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([comments count] == 0) {
        return 204;
    }

    DGComment * comment = comments[indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:13];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:[comment commentWithUsername] attributes:@ { NSFontAttributeName: font }];

    CGFloat height = [DGAppearance calculateHeightForText:attributedText andWidth:kCommentRightColumnWidth];

    CGFloat cellHeight = MAX(63, height + 30);
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if ([comments count] == 0) {
        return 1; // a single cell to report no data
    }
    return [comments count];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - Comment posting
- (IBAction)postComment:(id)sender {
    DGComment *newComment = [DGComment new];
    newComment.comment = commentInputField.text;
    newComment.commentable_id = self.good.goodID;
    newComment.commentable_type = @"Good";
    newComment.user_id = [DGUser currentUser].userID;

    // filter out non-user entities
    NSMutableArray *userEntities = [[NSMutableArray alloc] init];
    for (DGEntity *entity in entities) {
        if ([entity.link_type isEqualToString:@"user"]) {
            [userEntities addObject:entity];
        }
    }

    newComment.entities = userEntities;
    if (![commentInputField.text isEqualToString:@""]) {
        [[RKObjectManager sharedManager] postObject:newComment path:@"/comments" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

            [commentInputView becomeFirstResponder];
            commentInputField.text = @"";
            [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Comment Saved!", nil) subtitle:nil type:TSMessageNotificationTypeSuccess];
            [entities removeAllObjects];
            // [self fetchComments];
            [self textViewDidChange:commentInputField];
            [self resetTextView];
            [self addComment:[mappingResult.array objectAtIndex:0]];

            /* Add comment to previous page...
            self.good.comments = comments;
            // use metadata eventually
            self.good.comments_count = [NSNumber numberWithInt: [comments count]];
            self.goodCell.good = self.good;
            [self.goodCell reloadCell];
            */
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [TSMessage showNotificationInViewController:self.navigationController title:NSLocalizedString(@"Couldn't save the comment", nil) subtitle:NSLocalizedString([error localizedDescription], nil) type:TSMessageNotificationTypeError];

            DebugLog(@"error %@", [error description]);
        }];
    }
}

- (void)addComment:(DGComment *)comment {
    [comments insertObject:comment atIndex:0];
    // [comments addObject:comment];
    [tableView reloadData];
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

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    commentFieldBottom.constant = 0;
    tableViewBottom.constant = 44;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - UITextViewDelegate methods
- (BOOL)textViewShouldReturn:(UITextView *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self postComment:textField];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

- (BOOL)textView:(UITextView *)textField shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)string {
    if ([string isEqualToString:@"\n"]) {
        if (![textField.text isEqualToString:@""]) {
           [self postComment:textField];
        } else {
            [textField resignFirstResponder];
        }
        return NO;
    }

    if (characterLimit == range.location) {
        return NO;
    }

    int length = commentInputField.text.length - range.length + string.length;

    [self setTextViewHeight];
    [entityHandler setLimitText];

    if (length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
   
    BOOL sup = [entityHandler check:textField range:(NSRange)range forEntities:entities completion:^BOOL(BOOL end, NSMutableArray *newEntities) {
        entities = newEntities;
        return end;
    }];
    [entityHandler resetTypingAttributes:commentInputField];
    return sup;
}

- (void)setTextViewHeight {
    CGFloat adjustmentIndex = [DGAppearance calculateHeightForText:commentInputField.attributedText andWidth:240] + 16;
    commentInputFieldHeight.constant = adjustmentIndex;
}

- (void)resetTextView {
    commentInputFieldHeight.constant = 30.0;
}

- (void)textViewDidChange:(UITextView *)textField {
    [entityHandler watchForEntities:textField];
    [entityHandler setLimitText];
    if ([textField.text length] >= characterLimit || [textField.text isEqualToString:@""]) {
        sendButton.enabled = NO;
    } else {
        sendButton.enabled = YES;
    }
}

@end
