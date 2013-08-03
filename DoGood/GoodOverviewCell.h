#import <UIKit/UIKit.h>

@interface GoodOverviewCell : UITableViewCell <UITextViewDelegate> {
}

@property (weak, nonatomic) IBOutlet UITextView *description;
@property (weak, nonatomic) IBOutlet UIImageView *image;

- (UIImage *)defaultImage;

@end
