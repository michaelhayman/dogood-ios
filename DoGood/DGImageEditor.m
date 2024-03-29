#import "HFImageEditorViewController+Private.h"
#import "DGImageEditor.h"

@interface DGImageEditor ()

@end

@implementation DGImageEditor

@synthesize  saveButton = _saveButton;

-(id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if(self) {
        self.cropRect = CGRectMake(0,0,320,320);
        self.minimumScale = 0.2;
        self.maximumScale = 10;
        self.rotateEnabled = NO;
        [[UIToolbar appearanceWhenContainedIn:[DGImageEditor class], nil] setBarTintColor:VIVID];
        [[UIToolbar appearanceWhenContainedIn:[DGImageEditor class], nil] setTintColor:[UIColor whiteColor]];
        [self.saveButton setTitleTextAttributes:@{ NSFontAttributeName: [UIFont fontWithName:@"Helvetica-Bold" size:18.0], } forState:UIControlStateNormal];
        self.cancelButton.tintColor = CRIMSON;
        self.saveButton.tintColor = PINEAPPLE;
    }
    return self;
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    self.saveButton = nil;
}



- (IBAction)setSquareAction:(id)sender
{
    self.cropRect = CGRectMake((self.frameView.frame.size.width-320)/2.0f, (self.frameView.frame.size.height-320)/2.0f, 320, 320);
    [self reset:YES];
}

- (IBAction)setLandscapeAction:(id)sender
{
    self.cropRect = CGRectMake((self.frameView.frame.size.width-320)/2.0f, (self.frameView.frame.size.height-240)/2.0f, 320, 240);
    [self reset:YES];
}


- (IBAction)setLPortraitAction:(id)sender
{
    self.cropRect = CGRectMake((self.frameView.frame.size.width-240)/2.0f, (self.frameView.frame.size.height-320)/2.0f, 240, 320);
    [self reset:YES];
}

#pragma mark Hooks
- (void)startTransformHook
{
    // self.saveButton.tintColor = [UIColor colorWithRed:0 green:49/255.0f blue:98/255.0f alpha:1];
}

- (void)endTransformHook
{
    // self.saveButton.tintColor = [UIColor colorWithRed:0 green:128/255.0f blue:1 alpha:1];
}


@end
