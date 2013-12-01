#import "DGPostGoodNomineeAddViewController.h"
#import "DGNominee.h"

@implementation DGPostGoodNomineeAddViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (void)fillInNominee:(DGNominee *)theNominee {
    nominee = theNominee;
    nameField.text = nominee.fullName;
}

- (IBAction)nominate:(id)sender {
    if ([self.delegate respondsToSelector:@selector(childViewController:didChooseNominee:)]) {
        [self.delegate childViewController:self didChooseNominee:nominee];
    }
}

@end
