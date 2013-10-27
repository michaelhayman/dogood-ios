@interface HighlightCollectionCell : UICollectionViewCell {
    __weak IBOutlet UILabel *tagName;
}

@property (weak, nonatomic) UINavigationController *navigationController;

- (void)setName:(NSString *)string;

@end
