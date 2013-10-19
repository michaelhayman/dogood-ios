#import "DGEntityHandler.h"
#import "DGGood.h"
#import "GoodCell.h"
#import "DGComment.h"
#import "CommentCell.h"
#import "DGEntity.h"
#import "DGTextFieldSearchPeopleTableViewController.h"
#import "DGAppearance.h"

@interface DGEntityHandler ()

@end

#define kToolbarHeight 40
#define kCommentFieldHeight 44

@implementation DGEntityHandler

- (id)initWithTextView:(UITextView *)textView andEntities:(NSMutableArray *)inputEntities inController:(UIViewController *)controller withType:(NSString *)type
{
    self = [super init];
    if (self) {
        entityTextView = textView;
        entities = inputEntities;
        entityType = type;
        parent = controller;
        characterLimit = 120;
        [self setupAccessoryView];
        [self setupSearchPeopleTable];
    }
    return self;
}

- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)theseEntities completion:(CheckEntitiesBlock)completion {
     for (DGEntity *entity in theseEntities) {
        DebugLog(@"entity");
        NSRange entityRange = [entity rangeFromArray];
        NSRange intersection = NSIntersectionRange(range, [entity rangeFromArray]);
        entityRange.length = entityRange.length;
        if (intersection.length <= 0)
            DebugLog(@"Ranges do not intersect, continue as normal.");
        else {
            DebugLog(@"Intersection = %@", NSStringFromRange(intersection));
            UITextRange *selectedTextRange = [textField selectedTextRange];

            // range of entity if it is not currently selected
            UITextPosition *newPosition = [textField positionFromPosition:selectedTextRange.start offset:-entityRange.length];
            UITextRange *newTextRange = [textField textRangeFromPosition:newPosition toPosition:selectedTextRange.start];

            // range of entity if it is currently selected
            UITextPosition *anotherPosition = [textField positionFromPosition:selectedTextRange.start offset:entityRange.length];
            UITextRange *anotherTextRange = [textField textRangeFromPosition:selectedTextRange.start toPosition:anotherPosition];

            if ([selectedTextRange isEqual:anotherTextRange]) {
                [theseEntities removeObject:entity];
                [self resetTypingAttributes:textField];
                completion(YES, theseEntities);
                return YES;
            } else if (![selectedTextRange isEqual:newTextRange]) {
                completion(YES, theseEntities);
                [textField setSelectedTextRange:newTextRange];
                return NO;
            }
        }
    }
    return YES;
}

- (void)watchForEntities:(UITextView *)textField {
    if (searchPeople) {
        if ([textField.text length] >= startOfRange) {
            searchTerm = [textField.text substringFromIndex:startOfRange];
            [self searchPeople:searchTerm];
            return;
        } else {
            [self stopSearchingPeople];
            accessoryButtonMention.selected = NO;
        }
    }

    if (searchTags) {
        if ([textField.text length] >= startOfRange) {
            searchTerm = [textField.text substringFromIndex:startOfRange];
            // [self searchTags:searchTerm];
            return;
        } else {
            // [self stopSearchingTags];
            accessoryButtonTag.selected = NO;
        }

    }

    searchTerm = @"";

    if ([textField.text hasSuffix:@"@"] && accessoryButtonTag.selected == NO) {
        DebugLog(@"pop open table & start searching, and don't stop until 0 results are found");
        [self startSearchingPeople];
        startOfRange = [textField.text length];
        [self searchPeople:nil];
        // save start of range here
    }

    if ([textField.text hasSuffix:@"#"] && accessoryButtonMention.selected == NO) {
        DebugLog(@"pop open hash table & color following text up to a space");
        // searchTags = YES;
    }
}

#pragma mark - Keyboard management
- (void)setupAccessoryView {
    accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, kToolbarHeight)];

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

    characterLimitLabel = [[UILabel alloc] initWithFrame:CGRectMake(275, 10, 35, 23)];
    characterLimitLabel.textAlignment = NSTextAlignmentRight;
    characterLimitLabel.backgroundColor = [UIColor clearColor];
    [self setLimitText];
    [accessoryView addSubview:characterLimitLabel];
    [entityTextView setInputAccessoryView:accessoryView];
}

- (void)setLimitText {
    characterLimitLabel.text = [NSString stringWithFormat:@"%d", characterLimit - [entityTextView.text length]];
    if ([entityTextView.text length] >= characterLimit) {
        characterLimitLabel.textColor = [UIColor redColor];
    } else {
        characterLimitLabel.textColor = [UIColor blackColor];
    }
}

#pragma mark - People
- (void)selectPeople:(id)sender {
    if (accessoryButtonMention.selected == NO && accessoryButtonTag.selected == NO) {
        accessoryButtonMention.selected = !accessoryButtonMention.selected;
        entityTextView.attributedText = [self insert:@"@" atEndOf:entityTextView.attributedText];
        [self watchForEntities:entityTextView];
        [self resetTypingAttributes:entityTextView];
    }
}

- (NSAttributedString *)insert:(NSString *)string atEndOf:(NSAttributedString *)textField {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:textField];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:LINK_COLOUR forKey:NSForegroundColorAttributeName];
    NSAttributedString *extraCharacters = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [mutableString appendAttributedString:extraCharacters];
    DebugLog(@"umm");
    return mutableString;
}

- (void)searchPeople:(NSString *)text {
    [searchPeopleTableController getUsersByName:text];
}

- (void)setupSearchPeopleTable {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearchingPeople) name:DGUserDidNotFindPeopleForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPerson:) name:DGUserDidSelectPersonForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    searchTable = [[UITableView alloc] init];
    searchTable.transform = CGAffineTransformMakeRotation(-M_PI);
    searchPeopleTableController =  [[DGTextFieldSearchPeopleTableViewController alloc] init];
    searchPeopleTableController.tableView = searchTable;
    searchTable.delegate = searchPeopleTableController;
    searchTable.dataSource = searchPeopleTableController;
    searchTable.hidden = YES;
    [parent.view addSubview:searchTable];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [searchTable registerNib:nib forCellReuseIdentifier:@"UserCell"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    totalKeyboardHeight = keyboardSize.height + kCommentFieldHeight;
}

- (void)startSearchingPeople {
    searchTable.hidden = NO;
    searchPeople = YES;
    accessoryButtonMention.selected = YES;
    searchTable.frame = CGRectMake(0, 0, 320, parent.view.frame.size.height - totalKeyboardHeight);
}

- (void)stopSearchingPeople {
    accessoryButtonMention.selected = NO;
    searchTable.hidden = YES;
    searchPeople = NO;
    [searchPeopleTableController purge];
    [self resetTypingAttributes:entityTextView];
}

// here take an arbitrary string 
- (void)selectedPerson:(NSNotification *)notification {
    DGUser *user = [[notification userInfo] valueForKey:@"user"];
    // the idea here is to
    // strip out the @ symbol from the textfield on insertion
    int startOfPersonRange = startOfRange - 1;
    int personLength = [user.full_name length];
    int endOfPersonRange = startOfPersonRange + personLength;

    NSMutableAttributedString *originalComment = (NSMutableAttributedString *)[entityTextView.attributedText attributedSubstringFromRange:NSMakeRange(0, startOfPersonRange)];
    entityTextView.attributedText = [self insert:[user.full_name stringByAppendingString:@" "] atEndOf:originalComment];
    [self setLimitText];

    NSRange range = NSMakeRange(startOfPersonRange, endOfPersonRange - startOfPersonRange);

    DGEntity *entity = [DGEntity new];
    [entity setArrayFromRange:range];
    entity.entityable_type = entityType;
    entity.entityable_id = user.userID;
    entity.title = user.full_name;
    entity.link = [NSString stringWithFormat:@"dogood://users/%@", user.userID];
    entity.link_id = user.userID;
    entity.link_type = @"user";
    [entities addObject:entity];

    [self stopSearchingPeople];
}

#pragma mark - Tags
- (void)selectTag:(id)sender {
    if (accessoryButtonMention.selected == NO && accessoryButtonTag.selected == NO) {
        accessoryButtonTag.selected = !accessoryButtonTag.selected;
        [self resetTypingAttributes:entityTextView];
        entityTextView.attributedText = [self insert:@"#" atEndOf:entityTextView.attributedText];
        // entityTextView.text = [entityTextView.text stringByAppendingString:@"#"];
        [self textViewDidChange:entityTextView];
    }
}

- (void)startSearchingTags {

}

- (void)resetTypingAttributes:(UITextView *)textField {
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    textField.typingAttributes = attributes;
}

@end
