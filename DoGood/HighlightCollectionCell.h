@interface HighlightCollectionCell : UICollectionViewCell {
    __weak IBOutlet UILabel *tagName;
    __weak IBOutlet UIImageView *icon;
}

@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setName:(NSString *)string;
- (void)setName:(NSString *)string backgroundColor:(UIColor *)color andIcon:(UIImage *)image;

@end
