#import "DGEntityHandler.h"
#import "DGEntity.h"
#import "DGTag.h"
#import "DGTextFieldSearchPeopleTableViewController.h"
#import "DGTextFieldSearchTagsTableViewController.h"

@interface DGEntityHandler ()

@end

#define kToolbarHeight 40
#define kCommentFieldHeight 44

@implementation DGEntityHandler

- (id)initWithTextView:(UITextView *)textView andEntities:(NSMutableArray *)inputEntities inController:(UIViewController *)controller withType:(NSString *)type reverseScroll:(BOOL)reverse tableOffset:(int)firstOffset secondTableOffset:(int)secondOffset
{
    self = [super init];
    if (self) {
        entityTextView = textView;
        entities = inputEntities;
        entityType = type;
        parent = controller;
        characterLimit = 120;
        tableOffset = firstOffset;
        secondTableOffset = secondOffset;
        reverseScroll = reverse;
        [self setupAccessoryView];
        [self setupSearchPeopleTable];
        [self setupSearchTagsTable];
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

    if ([textField.text isEqualToString:@""])
        // if word has a @ at the start of it,
        // searchPeople = YES;
        // startOfRange = just after the @
    {
    }

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
            [self searchTags:searchTerm];
            return;
        } else {
            [self stopSearchingTags];
            accessoryButtonTag.selected = NO;
        }

    }

    searchTerm = @"";

    if ([textField.text hasSuffix:@"@"] && accessoryButtonTag.selected == NO) {
        [self startSearchingPeople];
        startOfRange = [textField.text length];
        [self searchPeople:nil];
    }

    if ([textField.text hasSuffix:@"#"] && accessoryButtonMention.selected == NO) {
        [self startSearchingTags];
        startOfRange = [textField.text length];
        [self searchTags:nil];
    }
}

#pragma mark - Keyboard management
- (void)setupAccessoryView {
    accessoryView = [[UIInputView alloc] initWithFrame:CGRectMake(0, 0, 320, kToolbarHeight) inputViewStyle:UIInputViewStyleKeyboard];

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
        [entityTextView.delegate textViewDidChange:entityTextView];
        [self watchForEntities:entityTextView];
        [self resetTypingAttributes:entityTextView];
    }
}

- (NSMutableAttributedString *)insert:(NSString *)string atEndOf:(NSAttributedString *)textField {
    NSMutableAttributedString *mutableString = [[NSMutableAttributedString alloc] initWithAttributedString:textField];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:LINK_COLOUR forKey:NSForegroundColorAttributeName];
    NSAttributedString *extraCharacters = [[NSAttributedString alloc] initWithString:string attributes:attributes];
    [mutableString appendAttributedString:extraCharacters];
    return mutableString;
}

- (void)searchPeople:(NSString *)text {
    [searchPeopleTableController getUsersByName:text];
}

- (void)searchTags:(NSString *)text {
    [searchTagsTableController getTagsByName:text];
}

- (void)setupSearchPeopleTable {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearchingPeople) name:DGUserDidNotFindPeopleForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedPerson:) name:DGUserDidSelectPersonForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    searchTable = [[UITableView alloc] init];
    searchPeopleTableController =  [[DGTextFieldSearchPeopleTableViewController alloc] initWithScrolling:reverseScroll];
    searchPeopleTableController.tableView = searchTable;
    searchTable.delegate = searchPeopleTableController;
    searchTable.dataSource = searchPeopleTableController;
    searchTable.hidden = YES;
    [parent.view addSubview:searchTable];

    UINib *nib = [UINib nibWithNibName:@"UserCell" bundle:nil];
    [searchTable registerNib:nib forCellReuseIdentifier:@"UserCell"];
}

- (void)setupSearchTagsTable {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(stopSearchingTags) name:DGUserDidNotFindTagsForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(selectedTag:) name:DGUserDidSelectTagForTextField object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];

    searchTagsTable = [[UITableView alloc] init];

    if (reverseScroll) {
        searchTagsTable.transform = CGAffineTransformMakeRotation(-M_PI);
    }

    searchTagsTableController =  [[DGTextFieldSearchTagsTableViewController alloc] initWithScrolling:reverseScroll];
    searchTagsTableController.tableView = searchTagsTable;
    searchTagsTable.delegate = searchTagsTableController;
    searchTagsTable.dataSource = searchTagsTableController;
    searchTagsTable.hidden = YES;
    [parent.view addSubview:searchTagsTable];
    UINib *nib = [UINib nibWithNibName:@"TagCell" bundle:nil];
    [searchTagsTable registerNib:nib forCellReuseIdentifier:@"TagCell"];
}

- (void)keyboardWillShow:(NSNotification *)notification {
    CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    totalKeyboardHeight = keyboardSize.height;
}

- (void)startSearchingPeople {
    searchTable.hidden = NO;
    searchPeople = YES;
    accessoryButtonMention.selected = YES;
    searchTable.frame = CGRectMake(0, tableOffset, 320, parent.view.frame.size.height - totalKeyboardHeight - (tableOffset + secondTableOffset));
}

- (void)stopSearchingPeople {
    accessoryButtonMention.selected = NO;
    searchTable.hidden = YES;
    searchPeople = NO;
    [searchPeopleTableController purge];
    [self resetTypingAttributes:entityTextView];
}

// here take an arbitrary string
// the idea here is to
// strip out the @ symbol from the textfield on insertion
- (void)selectedPerson:(NSNotification *)notification {
    DGUser *user = [[notification userInfo] valueForKey:@"user"];
    int startOfPersonRange = MAX(0, startOfRange - 1);
    int personLength = [user.full_name length];
    int endOfPersonRange = startOfPersonRange + personLength;

    DebugLog(@"debugging info: %i %@", startOfPersonRange, entityTextView.attributedText);
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
        entityTextView.attributedText = [self insert:@"#" atEndOf:entityTextView.attributedText];
        [entityTextView.delegate textViewDidChange:entityTextView];
        [self watchForEntities:entityTextView];
        [self resetTypingAttributes:entityTextView];
    }
}

- (void)startSearchingTags {
    searchTagsTable.hidden = NO;
    searchTags = YES;
    accessoryButtonTag.selected = YES;
    searchTagsTable.frame = CGRectMake(0, tableOffset, 320, parent.view.frame.size.height - totalKeyboardHeight - (tableOffset + secondTableOffset));
}

- (void)stopSearchingTags {
    accessoryButtonTag.selected = NO;
    searchTagsTable.hidden = YES;
    searchTags = NO;
    [searchTagsTableController purge];
    [self resetTypingAttributes:entityTextView];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)selectedTag:(NSNotification *)notification {
    DGTag *tag = [[notification userInfo] valueForKey:@"tag"];

    int startOfTagRange = MAX(-1, startOfRange);
    int personLength = [tag.name length];
    int endOfPersonRange = startOfTagRange + personLength;

    NSString *entityName = tag.name;
    NSMutableAttributedString *originalComment = (NSMutableAttributedString *)[entityTextView.attributedText attributedSubstringFromRange:NSMakeRange(0, startOfTagRange)];

    NSDictionary *attributes = [NSDictionary dictionaryWithObject:LINK_COLOUR forKey:NSForegroundColorAttributeName];
    originalComment = [self insert:[entityName stringByAppendingString:@" "] atEndOf:originalComment];
    [originalComment addAttributes:attributes range:NSMakeRange(startOfTagRange, 1)];

    entityTextView.attributedText = originalComment;
    [self setLimitText];

    NSRange range = NSMakeRange(startOfTagRange, endOfPersonRange - startOfTagRange);

    DGEntity *entity = [DGEntity new];
    [entity setArrayFromRange:range];
    entity.entityable_type = entityType;
    entity.entityable_id = tag.tagID;
    entity.title = tag.name;
    entity.link = [NSString stringWithFormat:@"dogood://goods/tagged/%@", tag.tagID];
    entity.link_id = tag.tagID;
    entity.link_type = @"tag";
    [entities addObject:entity];

    [self stopSearchingTags];
}

- (void)resetTypingAttributes:(UITextView *)textField {
    NSDictionary *attributes = [NSDictionary dictionaryWithObject:[UIColor blackColor] forKey:NSForegroundColorAttributeName];
    textField.typingAttributes = attributes;
}

@end
