@class DGReward;

@interface DGRewardPopupViewController : UIViewController <UIAlertViewDelegate> {
}

@property (weak, nonatomic) DGReward *reward;
@property BOOL claimed;

@end
