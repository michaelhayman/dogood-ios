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

@synthesize commentInputField;

- (BOOL)check:(UITextView *)textField range:(NSRange)range forEntities:(NSMutableArray *)entities completion:(CheckEntitiesBlock)completion {
     for (DGEntity *entity in entities) {
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
                [entities removeObject:entity];
                completion(YES, entities);
                return YES;
            } else if (![selectedTextRange isEqual:newTextRange]) {
                completion(YES, entities);
                [textField setSelectedTextRange:newTextRange];
                return NO;
            }
        }
    }
    return YES;
}

/*
#pragma mark - View lifecycle
- (void)initialize {
    advanced = YES;

    // accessories
    characterLimit = 120;
    [self setupAccessoryView];

    // entities
    entities = [[NSMutableArray alloc] init];
    [self setupSearchPeopleTable];
}

#pragma mark - Keyboard management
- (void)setupAccessoryView {
    accessoryView = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 0, 320, kToolbarHeight)];

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

- (void)setLimitText {
    characterLimitLabel.text = [NSString stringWithFormat:@"%d", characterLimit - [commentInputField.text length]];
    if ([commentInputField.text length] >= characterLimit) {
        characterLimitLabel.textColor = [UIColor redColor];
        sendButton.enabled = NO;
    } else {
        characterLimitLabel.textColor = [UIColor blackColor];
        sendButton.enabled = YES;
    }
}

#pragma mark - People
- (void)selectPeople:(id)sender {
    if (accessoryButtonMention.selected == NO && accessoryButtonTag.selected == NO) {
        accessoryButtonMention.selected = !accessoryButtonMention.selected;
        [self resetTypingAttributes:commentInputField];
        DebugLog(@"attributed text... %@", commentInputField.attributedText);
        commentInputField.attributedText = [self insert:@"@" atEndOf:commentInputField.attributedText];
        DebugLog(@"attributed text... %@", commentInputField.attributedText);
        [self textViewDidChange:commentInputField];
        [self resetTypingAttributes:commentInputField];
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
}

// here take an arbitrary string 
- (void)selectedPerson:(NSNotification *)notification {
    DGUser *user = [[notification userInfo] valueForKey:@"user"];
    // the idea here is to
    // strip out the @ symbol from the textfield on insertion
    int startOfPersonRange = startOfRange - 1;
    int personLength = [user.full_name length];
    int endOfPersonRange = startOfPersonRange + personLength;

    NSMutableAttributedString *originalComment = (NSMutableAttributedString *)[commentInputField.attributedText attributedSubstringFromRange:NSMakeRange(0, startOfPersonRange)];
    commentInputField.attributedText = [self insert:[user.full_name stringByAppendingString:@" "] atEndOf:originalComment];
    [self setLimitText];

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

#pragma mark - Tags
- (void)selectTag:(id)sender {
    if (accessoryButtonMention.selected == NO && accessoryButtonTag.selected == NO) {
        accessoryButtonTag.selected = !accessoryButtonTag.selected;
        [self resetTypingAttributes:commentInputField];
        commentInputField.attributedText = [self insert:@"#" atEndOf:commentInputField.attributedText];
        // commentInputField.text = [commentInputField.text stringByAppendingString:@"#"];
        [self textViewDidChange:commentInputField];
    }
}

- (void)startSearchingTags {

}
*/

@end
