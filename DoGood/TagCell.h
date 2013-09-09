@class DGTag;

@interface TagCell : UITableViewCell {
    __weak IBOutlet UILabel *tagName;
}

@property (weak, nonatomic) DGTag *taggage;
@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setValues;

@end
