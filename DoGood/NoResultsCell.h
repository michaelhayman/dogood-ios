@interface NoResultsCell : UITableViewCell {
}

@property (weak, nonatomic) IBOutlet UILabel *heading;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headingHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headingSpacer;
@property (weak, nonatomic) IBOutlet UILabel *explanation;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *explanationHeight;
@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imageSpacer;

- (void)setHeading:(NSString *)heading andExplanation:(NSString *)explanation;
- (void)setHeading:(NSString *)heading explanation:(NSString *)explanation andImage:(UIImage *)image;

@end
