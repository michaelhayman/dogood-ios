#import "DGGoodCommentsViewController.h"
#import "DGGood.h"
#import "GoodCell.h"
#import "DGComment.h"
#import "CommentCell.h"
#import "DGEntity.h"
#import "DGTextFieldSearchPeopleTableViewController.h"
#import "DGNotification.h"
#import "NoResultsCell.h"
#import "DGEntityHandler.h"
#import "UIScrollView+SVInfiniteScrolling.h"
#import <SAMLoadingView/SAMLoadingView.h>

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
    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [tableView registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];
    comments = [[NSMutableArray alloc] init];

    tableView.tableFooterView = [[UIView alloc] init];

    loadingView = [[SAMLoadingView alloc] initWithFrame:self.view.bounds];
    loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    loadingStatus = @"Loading...";

    characterLimit = 120;
    entities = [[NSMutableArray alloc] init];
    commentInputField.allowsEditingTextAttributes = NO;
    entityHandler = [[DGEntityHandler alloc] initWithTextView:commentInputField andEntities:entities inController:self andLinkID:self.good.goodID reverseScroll:YES tableOffset:64 secondTableOffset:44 characterLimit:characterLimit];

    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    // [self setupKeyboardBehaviour];
    [self setupInfiniteScroll];

    [self reloadComments];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticate) name:DGUserDidFailSilentAuthenticationNotification object:nil];
}

- (void)authenticate {
    [[DGUser currentUser] authorizeAccess:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [DGMessage dismissActiveNotification];
    entityHandler = nil;
    // [commentInputField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self setupKeyboardBehaviour];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[DGTracker sharedTracker] trackScreen:@"Comment List"];
}

#pragma mark - Comment retrieval ----------
- (void)getComments {
    [DGComment getCommentsForGood:self.good page:page completion:^(NSArray *retrievedComments, NSError *error) {
        if (error) {
            loadingStatus = @"Couldn't connect";

            [loadingView removeFromSuperview];
            DebugLog(@"Operation failed with error: %@", error);
            [tableView reloadData];
            return;
        }

        [comments addObjectsFromArray:retrievedComments];
        loadingStatus = @"No comments posted yet";

        [tableView reloadData];
        [tableView.infiniteScrollingView stopAnimating];
        [loadingView removeFromSuperview];
        DebugLog(@"reloading data");
    }];
}

- (void)loadMoreComments {
    page++;
    [self getComments];
}

- (void)resetComments {
    page = 1;
    [comments removeAllObjects];
}

- (void)reloadComments {
    [self.view addSubview:loadingView];
    [self resetComments];
    [self getComments];
}

- (void)setupInfiniteScroll {
    tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    __weak DGGoodCommentsViewController *weakSelf = self;
    __weak UITableView *weakTableView = tableView;

    [tableView addInfiniteScrollingWithActionHandler:^{
        __strong DGGoodCommentsViewController *strongSelf = weakSelf;
        __strong UITableView *strongTableView = weakTableView;
        [strongTableView.infiniteScrollingView startAnimating];
        [strongSelf loadMoreComments];
    }];
}

#pragma mark - UITableViewDelegate methods
- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([comments count] == 0) {
        tableView.transform = CGAffineTransformMakeRotation(M_PI);
        static NSString * reuseIdentifier = kNoResultsCell;
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell setHeading:nil andExplanation:loadingStatus];
        [cell setHeading:nil explanation:loadingStatus andImage:[UIImage imageNamed:@"NoComments"]];
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
        return 150;
    }

    DGComment * comment = comments[indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:13];

    CGFloat height = [DGAppearance calculateHeightForString:[comment commentWithUsername] WithFont:font andWidth:[DGComment commentBoxWidth]];

    CGFloat cellHeight = MAX(63, height + 30);
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if ([comments count] == 0) {
        tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 1; // a single cell to report no data
    } else {
        tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return [comments count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - Comment posting
- (IBAction)postComment:(id)sender {
    sendButton.enabled = NO;
    DGComment *newComment = [DGComment new];
    newComment.comment = commentInputField.text;
    newComment.commentable_id = self.good.goodID;
    newComment.commentable_type = @"Good";
    newComment.user_id = [DGUser currentUser].userID;

    // filter out non-user entities
    NSMutableArray *parsedEntities = [[NSMutableArray alloc] init];
    for (DGEntity *entity in entities) {
        if ([entity.link_type isEqualToString:@"user"]) {
            [parsedEntities addObject:entity];
        }
    }

    // re-add tag entities
    [DGEntity findTagEntitiesIn:newComment.comment forLinkID:self.good.goodID completion:^(NSArray *tagEntities, NSError *error) {
        [parsedEntities addObjectsFromArray:tagEntities];
    }];

    newComment.entities = parsedEntities;

    if (![commentInputField.text isEqualToString:@""]) {
        [DGComment postComment:newComment completion:^(DGComment *comment, NSError *error) {
            sendButton.enabled = YES;

            if (error) {
                DebugLog(@"error %@", [error description]);
                [DGMessage showErrorInViewController:self.navigationController title:NSLocalizedString(@"Couldn't save the comment", nil) subtitle:NSLocalizedString([error localizedDescription], nil)];
                return;
            }

            [commentInputView becomeFirstResponder];

            commentInputField.text = @"";

            [DGMessage showSuccessInViewController:self.navigationController title:NSLocalizedString(@"Comment Saved!", nil) subtitle:nil];

            [entities removeAllObjects];

            [self textViewDidChange:commentInputField];
            [self resetTextView];
            [self addComment:newComment];

            [DGNotification promptForNotifications];
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
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        commentFieldBottom.constant = keyboardSize.height;
    } else {
        commentFieldBottom.constant = keyboardSize.width;
    }
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

    NSInteger length = commentInputField.text.length - range.length + string.length;

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

- (CGFloat)commentInputFieldWidth {
    if (iPad) {
        UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
        if (UIInterfaceOrientationIsPortrait(orientation)) {
            return 704;
        } else {
            return 960;
        }
    } else {
        return 256 - 16;
    }
}

- (void)setTextViewHeight {
    CGFloat adjustmentIndex = [DGAppearance calculateHeightForText:commentInputField.attributedText andWidth:[self commentInputFieldWidth]] + 16;
    commentInputFieldHeight.constant = adjustmentIndex;
}

- (void)resetTextView {
    commentInputFieldHeight.constant = 30.0;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 addTarget:self action:@selector(closeComments) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"KeyboardDown"] forState:UIControlStateNormal];
    [a1 sizeToFit];
    UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.rightBarButtonItem = hideButton;
}

- (void)closeComments {
    [commentInputField resignFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
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
