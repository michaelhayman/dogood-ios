@interface UserGoodCell : UITableViewCell {
}

@property (weak, nonatomic) IBOutlet UIImageView *icon;
@property (weak, nonatomic) IBOutlet UILabel *sectionName;

- (void)enable;
- (void)disable;

@end
