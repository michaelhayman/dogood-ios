#import "DGPostGoodNomineeAddViewController.h"

@implementation DGPostGoodNomineeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)nominate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(childViewController:didChooseNominee:)]) {
        [self.delegate childViewController:self didChooseNominee:nominee];
    }
}

@end
