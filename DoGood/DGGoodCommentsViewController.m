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

#pragma mark - UIViewController
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupMenuTitle:@"Comments"];
    self.sendButton.enabled = NO;

    // comments list
    UINib *nib = [UINib nibWithNibName:kCommentCell bundle:nil];
    [self.tableView registerNib:nib forCellReuseIdentifier:kCommentCell];
    UINib *noResultsNib = [UINib nibWithNibName:kNoResultsCell bundle:nil];
    [self.tableView registerNib:noResultsNib forCellReuseIdentifier:kNoResultsCell];
    self.comments = [[NSMutableArray alloc] init];

    self.tableView.tableFooterView = [[UIView alloc] init];

    self.loadingView = [[SAMLoadingView alloc] initWithFrame:self.view.bounds];
    self.loadingView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.loadingStatus = @"Loading...";

    self.characterLimit = 120;
    self.entities = [[NSMutableArray alloc] init];
    self.commentInputField.allowsEditingTextAttributes = NO;
    self.entityHandler = [[DGEntityHandler alloc] initWithTextView:self.commentInputField andEntities:self.entities inController:self andLinkID:self.good.goodID reverseScroll:YES tableOffset:64 secondTableOffset:44 characterLimit:self.characterLimit];

    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    // [self setupKeyboardBehaviour];
    [self setupInfiniteScroll];

    [self reloadComments];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    DebugLog(@"sup?");
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [DGMessage dismissActiveNotification];
    self.entityHandler = nil;
    // [self.commentInputField resignFirstResponder];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:DGUserDidFailSilentAuthenticationNotification object:nil];
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

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(authenticate) name:DGUserDidFailSilentAuthenticationNotification object:nil];
}

#pragma mark - Comment management

- (void)authenticate {
    [[DGUser currentUser] authorizeAccess:self];
}

- (void)getComments {
    [DGComment getCommentsForGood:self.good page:self.page completion:^(NSArray *retrievedComments, NSError *error) {
        if (error) {
            self.loadingStatus = @"Couldn't connect";

            [self.loadingView removeFromSuperview];
            DebugLog(@"Operation failed with error: %@", error);
            [self.tableView reloadData];
            return;
        }

        [self.comments addObjectsFromArray:retrievedComments];
        self.loadingStatus = @"No comments posted yet";

        [self.tableView reloadData];
        [self.tableView.infiniteScrollingView stopAnimating];
        [self.loadingView removeFromSuperview];
        DebugLog(@"reloading data");
    }];
}

- (void)loadMoreComments {
    self.page++;
    [self getComments];
}

- (void)resetComments {
    self.page = 1;
    [self.comments removeAllObjects];
}

- (void)reloadComments {
    [self.view addSubview:self.loadingView];
    [self resetComments];
    [self getComments];
}

- (void)setupInfiniteScroll {
    self.tableView.infiniteScrollingView.activityIndicatorViewStyle = UIActivityIndicatorViewStyleGray;

    __weak DGGoodCommentsViewController *weakSelf = self;
    __weak UITableView *weakTableView = self.tableView;

    [self.tableView addInfiniteScrollingWithActionHandler:^{
        __strong DGGoodCommentsViewController *strongSelf = weakSelf;
        __strong UITableView *strongTableView = weakTableView;
        [strongTableView.infiniteScrollingView startAnimating];
        [strongSelf loadMoreComments];
    }];
}

- (IBAction)postComment:(id)sender {
    self.sendButton.enabled = NO;
    DGComment *newComment = [DGComment new];
    newComment.comment = self.commentInputField.text;
    newComment.commentable_id = self.good.goodID;
    newComment.commentable_type = @"Good";
    newComment.user_id = [DGUser currentUser].userID;

    // filter out non-user entities
    NSMutableArray *parsedEntities = [[NSMutableArray alloc] init];
    for (DGEntity *entity in self.entities) {
        if ([entity.link_type isEqualToString:@"user"]) {
            [parsedEntities addObject:entity];
        }
    }

    // re-add tag entities
    [DGEntity findTagEntitiesIn:newComment.comment forLinkID:self.good.goodID completion:^(NSArray *tagEntities, NSError *error) {
        [parsedEntities addObjectsFromArray:tagEntities];
    }];

    newComment.entities = parsedEntities;

    if (![self.commentInputField.text isEqualToString:@""]) {
        [DGComment postComment:newComment completion:^(DGComment *comment, NSError *error) {
            self.sendButton.enabled = YES;

            if (error) {
                DebugLog(@"error %@", [error description]);
                [DGMessage showErrorInViewController:self.navigationController title:NSLocalizedString(@"Couldn't save the comment", nil) subtitle:NSLocalizedString([error localizedDescription], nil)];
                return;
            }

            [self.commentInputView becomeFirstResponder];

            self.commentInputField.text = @"";

            [DGMessage showSuccessInViewController:self.navigationController title:NSLocalizedString(@"Comment Saved!", nil) subtitle:nil];

            [self.entities removeAllObjects];

            [self textViewDidChange:self.commentInputField];
            [self resetTextView];
            [self addComment:newComment];

            [DGNotification promptForNotifications];
        }];
    }
}

- (void)addComment:(DGComment *)comment {
    [self.comments insertObject:comment atIndex:0];
    [self.tableView reloadData];
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
        return 240;
    }
}

#pragma mark - UITableViewDelegate

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.comments count] == 0) {
        self.tableView.transform = CGAffineTransformMakeRotation(M_PI);
        static NSString * reuseIdentifier = kNoResultsCell;
        NoResultsCell *cell = [aTableView dequeueReusableCellWithIdentifier:reuseIdentifier forIndexPath:indexPath];
        [cell setHeading:nil andExplanation:self.loadingStatus];
        [cell setHeading:nil explanation:self.loadingStatus andImage:[UIImage imageNamed:@"NoComments"]];
        cell.transform = CGAffineTransformMakeRotation(-M_PI);
        return cell;
    }
    self.tableView.transform = CGAffineTransformMakeRotation(-M_PI);

    CommentCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    DGComment * comment = self.comments[indexPath.row];
    cell.comment = comment;
    cell.navigationController = self.navigationController;
    [cell setValues];
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([self.comments count] == 0) {
        return 150;
    }

    DGComment * comment = self.comments[indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:13];

    CGFloat height = [DGAppearance calculateHeightForString:[comment commentWithUsername] WithFont:font andWidth:[DGComment commentBoxWidth]];

    CGFloat cellHeight = MAX(63, height + 30);
    return cellHeight;
}

- (NSInteger)tableView:(UITableView *)tblView numberOfRowsInSection:(NSInteger)section {
    if ([self.comments count] == 0) {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        return 1; // a single cell to report no data
    } else {
        self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
        return [self.comments count];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return @"";
}

#pragma mark - UIKeyboard

- (void)setupKeyboardBehaviour {
    if (self.makeComment) {
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.0];
        [UIView setAnimationDelay:0.0];
        [UIView setAnimationCurve:UIViewAnimationCurveLinear];

        [self.commentInputField becomeFirstResponder];

        NSLog(@"is first responder %d", self.commentInputField.isFirstResponder);
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
        DebugLog(@"not necessary");
    }

    [UIView setAnimationDuration:animationDuration];
    [UIView setAnimationCurve:animationCurve];
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];

    if (UIInterfaceOrientationIsPortrait(orientation)) {
        self.commentFieldBottom.constant = keyboardSize.height;
    } else {
        self.commentFieldBottom.constant = keyboardSize.width;
    }
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

- (void)keyboardWillHide:(NSNotification *)notification {
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:0.3];
    self.commentFieldBottom.constant = 0;
    [self.view layoutIfNeeded];
    [UIView commitAnimations];
}

#pragma mark - UITextView

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

    if (self.characterLimit == range.location) {
        return NO;
    }

    NSInteger length = self.commentInputField.text.length - range.length + string.length;

    [self setTextViewHeight];
    [self.entityHandler setLimitText];

    if (length > 0) {
        self.sendButton.enabled = YES;
    } else {
        self.sendButton.enabled = NO;
    }
   
    BOOL sup = [self.entityHandler check:textField range:range forEntities:self.entities completion:^BOOL(BOOL end, NSMutableArray *newEntities) {
        self.entities = newEntities;
        return end;
    }];

    [self.entityHandler resetTypingAttributes:self.commentInputField];
    return sup;
}

- (void)setTextViewHeight {
    CGFloat adjustmentIndex = [DGAppearance calculateHeightForText:self.commentInputField.attributedText andWidth:[self commentInputFieldWidth]] + 16;
    self.commentInputFieldHeight.constant = adjustmentIndex;
}

- (void)resetTextView {
    self.commentInputFieldHeight.constant = 30.0;
}

- (void)textViewDidBeginEditing:(UITextView *)textView {
    UIButton *a1 = [UIButton buttonWithType:UIButtonTypeCustom];
    [a1 addTarget:self action:@selector(closeComments) forControlEvents:UIControlEventTouchUpInside];
    [a1 setImage:[UIImage imageNamed:@"KeyboardDown"] forState:UIControlStateNormal];
    [a1 sizeToFit];
    UIBarButtonItem *hideButton = [[UIBarButtonItem alloc] initWithCustomView:a1];
    self.navigationItem.rightBarButtonItem = hideButton;
}

- (void)textViewDidEndEditing:(UITextView *)textView {
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)textViewDidChange:(UITextView *)textField {
    [self.entityHandler watchForEntities:textField];
    [self.entityHandler setLimitText];
    if ([textField.text length] >= self.characterLimit || [textField.text isEqualToString:@""]) {
        self.sendButton.enabled = NO;
    } else {
        self.sendButton.enabled = YES;
    }
}

- (void)closeComments {
    [self.commentInputField resignFirstResponder];
}

@end
