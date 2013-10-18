#import "DGGoodCommentsViewController.h"
#import "DGGood.h"
#import "GoodCell.h"
#import "DGComment.h"
#import "CommentCell.h"
#import "DGEntity.h"
#import "DGTextFieldSearchPeopleTableViewController.h"

@interface DGGoodCommentsViewController ()

@end

#define kToolbarHeight 40
#define kCommentFieldHeight 44

@implementation DGGoodCommentsViewController

#pragma mark - View lifecycle
- (void)viewDidLoad {
    [super viewDidLoad];

    [self setupMenuTitle:@"Comments"];

    advanced = YES;

    // comments list
    UINib *nib = [UINib nibWithNibName:@"CommentCell" bundle:nil];
    [tableView registerNib:nib forCellReuseIdentifier:@"CommentCell"];
    comments = [[NSMutableArray alloc] init];
    [self fetchComments];

    // accessories
    characterLimit = 120;
    [self setupAccessoryView];
    [commentInputField addTarget:self action:@selector(textFieldDidChange:) forControlEvents:UIControlEventEditingChanged];
    commentInputField.allowsEditingTextAttributes = NO;

    // entities
    entities = [[NSMutableArray alloc] init];
    [self setupSearchPeopleTable];

    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [self setupKeyboardBehaviour];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    tableView.transform = CGAffineTransformMakeRotation(-M_PI);
    [TSMessage dismissActiveNotification];
}

// TODO: not sure why this is in will appear
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}

#pragma mark - Comment retrieval ----------
- (void)fetchComments {
    NSDictionary *params = [NSDictionary dictionaryWithObject:self.good.goodID forKey:@"good_id"];

    [[RKObjectManager sharedManager] getObjectsAtPath:@"/comments.json" parameters:params success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {
        [comments removeAllObjects];
        [comments addObjectsFromArray:mappingResult.array];

        [tableView reloadData];
        DebugLog(@"reloading data");
    } failure:^(RKObjectRequestOperation *operation, NSError *error) {
        DebugLog(@"Operation failed with error: %@", error);
    }];
    [tableView reloadData];
}

- (UITableViewCell *)tableView:(UITableView *)aTableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    CommentCell *cell = [aTableView dequeueReusableCellWithIdentifier:@"CommentCell"];
    cell.transform = CGAffineTransformMakeRotation(M_PI);
    DGComment * comment = comments[indexPath.row];
    cell.comment = comment;
    cell.navigationController = self.navigationController;
    [cell setValues];
    return cell;
}

- (CGFloat)tableView:(UITableView *)aTableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    DGComment * comment = comments[indexPath.row];
    UIFont *font = [UIFont systemFontOfSize:13];
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:comment.comment attributes:@ { NSFontAttributeName: font }];
    CGFloat width = 235;
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake(width, CGFLOAT_MAX)
                                               options:NSStringDrawingUsesLineFragmentOrigin
                                               context:nil];
    CGSize size = rect.size;
    CGFloat height = ceilf(size.height);

    return MAX(63, height + 22);
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

#pragma mark - Comment posting
- (IBAction)postComment:(id)sender {
    DGComment *newComment = [DGComment new];
    newComment.comment = commentInputField.text;
    newComment.commentable_id = self.good.goodID;
    newComment.commentable_type = @"Good";
    newComment.user_id = [DGUser currentUser].userID;
    newComment.entities = entities;
    if (![commentInputField.text isEqualToString:@""]) {
        [[RKObjectManager sharedManager] postObject:newComment path:@"/comments" parameters:nil success:^(RKObjectRequestOperation *operation, RKMappingResult *mappingResult) {

            [commentInputView becomeFirstResponder];
            commentInputField.text = @"";
            [TSMessage showNotificationInViewController:self.navigationController
                                  title:NSLocalizedString(@"Comment Saved!", nil)
                                subtitle:nil
                                   type:TSMessageNotificationTypeSuccess];
            [entities removeAllObjects];
            // [self fetchComments];
            [self addComment:[mappingResult.array objectAtIndex:0]];
            /* Add comment to previous page...
            self.good.comments = comments;
            // use metadata eventually
            self.good.comments_count = [NSNumber numberWithInt: [comments count]];
            self.goodCell.good = self.good;
            [self.goodCell reloadCell];
            */
        } failure:^(RKObjectRequestOperation *operation, NSError *error) {
            [TSMessage showNotificationInViewController:self.navigationController
                                      title:NSLocalizedString(@"Couldn't save the comment", nil)
                                               subtitle:NSLocalizedString([error description], nil)
                                       type:TSMessageNotificationTypeError];

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
    totalKeyboardHeight = keyboardSize.height + kCommentFieldHeight;
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

- (void)setupAccessoryView {
    accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, kToolbarHeight)];
    accessoryView.tintColor = [UIColor colorWithRed:0.569 green:0.600 blue:0.643 alpha:1.000];
    accessoryView.backgroundColor = [UIColor clearColor];

    if (advanced) {
        accessoryButtonMention = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryButtonMention setFrame:CGRectMake(10.0f, 10.0f, 26.0f, 23.0f)];
        [accessoryButtonMention setImage:[UIImage imageNamed:@"KeyboardMention"] forState:UIControlStateNormal];
        [accessoryButtonMention setImage:[UIImage imageNamed:@"KeyboardMentionActive"] forState:UIControlStateSelected];
        [accessoryButtonMention addTarget:self action:@selector(selectPeople:) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:accessoryButtonMention];

        accessoryButtonTag = [UIButton buttonWithType:UIButtonTypeCustom];
        [accessoryButtonTag setFrame:CGRectMake(50.0f, 10.0f, 33.0f, 23.0f)];
        [accessoryButtonTag setImage:[UIImage imageNamed:@"KeyboardTag"] forState:UIControlStateNormal];
        [accessoryButtonTag setImage:[UIImage imageNamed:@"KeyboardTagActive"] forState:UIControlStateSelected];
        [accessoryButtonTag addTarget:self action:@selector(selectTag:) forControlEvents:UIControlEventTouchUpInside];
        [accessoryView addSubview:accessoryButtonTag];
    }

    characterLimitLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 10, 35, 23)];
    characterLimitLabel.textAlignment = NSTextAlignmentRight;
    characterLimitLabel.backgroundColor = [UIColor clearColor];
    [self setLimitText];
    [accessoryView addSubview:characterLimitLabel];
}

- (void)dismissKeyboard {
    [commentInputField resignFirstResponder];
}

- (void)setLimitText {
    characterLimitLabel.text = [NSString stringWithFormat:@"%d", characterLimit - [commentInputField.text length]];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    if (![textField.text isEqualToString:@""]) {
        [self postComment:textField];
    } else {
        [textField resignFirstResponder];
    }
    return NO;
}

-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    for (DGEntity *entity in entities) {
        NSRange entityRange = [entity rangeFromArray];
        NSRange intersection = NSIntersectionRange(range, [entity rangeFromArray]);
        if (intersection.length <= 0)
            DebugLog(@"Ranges do not intersect, continue");
        else {
            DebugLog(@"Intersection = %@", NSStringFromRange(intersection));
            UITextRange *selectedTextRange = [textField selectedTextRange];
            UITextPosition *newPosition = [textField positionFromPosition:selectedTextRange.start offset:entityRange.length];
            UITextRange *newTextRange = [textField textRangeFromPosition:newPosition toPosition:selectedTextRange.start];

            // Set new range
            if ([selectedTextRange isEqual:newTextRange]) {
                [entities removeObject:entity];
                return YES;
            } else {
                [textField setSelectedTextRange:newTextRange];
                return NO;
            }
        }
    }
    
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    textField.typingAttributes = attributes;
    int length = commentInputField.text.length - range.length + string.length;

    if (length > 0) {
        sendButton.enabled = YES;
    } else {
        sendButton.enabled = NO;
    }
    return YES;
}

-(void)textFieldDidBeginEditing:(UITextField *)textField{
    [commentInputField setInputAccessoryView:accessoryView];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {

}

- (void)textFieldDidChange:(UITextField *)textField {
    [self setLimitText];

    if (advanced) {
        if (searchPeople) {
            if ([textField.text length] >= startOfRange) {
                searchTerm = [textField.text substringFromIndex:startOfRange];
                [self searchPeople:searchTerm];
                return;
            } else {
                [self stopSearchingPeople];
            }
        }
        if (searchTags) {

        }

        searchTerm = @"";

        if ([textField.text hasSuffix:@"@"]) {
            DebugLog(@"pop open table & start searching, and don't stop until 0 results are found");
            [self startSearchingPeople];
            startOfRange = [textField.text length];
            // save start of range here
        }

        if ([textField.text hasSuffix:@"#"]) {
            DebugLog(@"pop open hash table & color following text up to a space");
            // searchTags = YES;
        }
    }
}

#pragma mark - People
- (void)selectPeople:(id)sender {
    accessoryButtonMention.selected = !accessoryButtonMention.selected;
    commentInputField.text = [commentInputField.text stringByAppendingString:@"@"];
    [self textFieldDidChange:commentInputField];
}

- (void)searchPeople:(NSString *)text {
    [searchPeopleTableController getUsersByName:text];
}

- (void)setupSearchPeopleTable {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearchingPeople) name:DGUserDidNotFindPeopleForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPerson:) name:DGUserDidSelectPersonForTextField object:nil];

    searchTable = [[UITableView alloc] init];
    searchTable.transform = CGAffineTransformMakeRotation(-M_PI);
    searchPeopleTableController =  [[DGTextFieldSearchPeopleTableViewController alloc] init];
    searchPeopleTableController.tableView = searchTable;
    searchTable.delegate = searchPeopleTableController;
    searchTable.dataSource = searchPeopleTableController;
    searchTable.hidden = YES;
    [self.view addSubview:searchTable];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [searchTable registerNib:nib forCellReuseIdentifier:@"UserCell"];
}

- (void)selectedPerson:(NSNotification *)notification {
    DGUser *user = [[notification userInfo] valueForKey:@"user"];
    int startOfPersonRange = startOfRange - 1;
    int personLength = [user.full_name length];
    int endOfPersonRange = startOfRange + personLength;

    NSMutableAttributedString *originalComment = (NSMutableAttributedString *)[commentInputField.attributedText attributedSubstringFromRange:NSMakeRange(0, startOfPersonRange)];

    NSDictionary *attributes = [NSDictionary dictionaryWithObject:LINK_COLOUR forKey:NSForegroundColorAttributeName];
    NSAttributedString *extraComment = [[NSAttributedString alloc] initWithString:[user.full_name stringByAppendingString:@" "] attributes:attributes];

    [originalComment appendAttributedString:extraComment];
    commentInputField.attributedText = originalComment;

    NSRange range = NSMakeRange(startOfPersonRange, endOfPersonRange - startOfPersonRange);

    DGEntity *entity = [DGEntity new];
    [entity setArrayFromRange:range];
    entity.entityable_type = @"Comment";
    entity.entityable_id = user.userID;
    entity.title = user.full_name;
    entity.link = [NSString stringWithFormat:@"dogood://users/%@", user.userID];
    entity.link_id = user.userID;
    entity.link_type = @"user";
    [entities addObject:entity];

    [self stopSearchingPeople];
}

- (void)startSearchingPeople {
    searchTable.hidden = NO;
    searchPeople = YES;
    accessoryButtonMention.selected = YES;
    searchTable.frame = CGRectMake(0, 0, 320, self.view.frame.size.height - totalKeyboardHeight);
}

- (void)stopSearchingPeople {
    accessoryButtonMention.selected = NO;
    searchTable.hidden = YES;
    searchPeople = NO;
    [searchPeopleTableController purge];
}

#pragma mark - Tags
- (void)selectTag:(id)sender {
    accessoryButtonTag.selected = !accessoryButtonTag.selected;
    commentInputField.text = [commentInputField.text stringByAppendingString:@"#"];
    [self textFieldDidChange:commentInputField];
}

- (void)startSearchingTags {

}

@end
