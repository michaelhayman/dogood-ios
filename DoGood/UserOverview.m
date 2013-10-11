#import "UserOverview.h"
#import "constants.h"

@implementation UserOverview

#pragma mark - Initialization & reuse
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [[NSBundle mainBundle] loadNibNamed:@"UserOverview" owner:self options:nil];
        [self addSubview:self.view];

        [self setContent];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self addSubview:self.view];
    [self setupNotifications];
}

- (void)setContent {
    self.username.text = [DGUser currentUser].username;
    [self updatePointsText];
}

- (void)style {
    // self.points.textColor = [UIColor whiteColor];
    // self.username.textColor = [UIColor whiteColor];
    // self.view.backgroundColor = COLOUR_REDDISH_BROWN;
}

- (void)setupNotifications {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidUpdatePointsNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updatePointsText) name:DGUserDidPostGood object:nil];
}

#pragma mark - Content methods
- (void)updatePointsText {
    self.points.text = [NSString stringWithFormat:@"%@ points", [[DGUser currentUser] pointsText]];
}

@end