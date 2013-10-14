#define TEXTVIEW_TEXT @"Tell the world about the good you did"

@interface GoodOverviewCell : UITableViewCell <UITextViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (UIImage *)defaultImage;

@end
