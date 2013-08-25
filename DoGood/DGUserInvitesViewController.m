#import "DGUserInvitesViewController.h"
#import <MessageUI/MessageUI.h>

@interface DGUserInvitesViewController () <
    MFMailComposeViewControllerDelegate,
    MFMessageComposeViewControllerDelegate>
@end

@implementation DGUserInvitesViewController

- (void)viewDidLoad {
}

- (IBAction)inviteViaText:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        [self displaySMSComposerSheet];
    }
    else {
		DebugLog(@"Device not configured to send SMS.");
    }
}

- (IBAction)inviteViaEmail:(id)sender {
    if ([MFMailComposeViewController canSendMail]) {
        [self displayMailComposerSheet];
    }
    else {
		DebugLog(@"Device not configured to send mail.");
    }
}

#pragma mark - Compose Mail/SMS
- (void)displayMailComposerSheet {
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	
	[picker setSubject:@"Do Good with me"];
	
	// Fill out the email body text
	NSString *emailBody = [NSString stringWithFormat:@"Get rewarded for doing good - follow me on Do Good! dogood://users/%@\n\n---\nDon't have Do Good? Get it from the App Store: https://get.dogood.co", [DGUser currentUser].userID];
	[picker setMessageBody:emailBody isHTML:NO];
	
	[_parent presentViewController:picker animated:YES completion:NULL];
}

- (void)displaySMSComposerSheet {
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
	
    picker.body = [NSString stringWithFormat:@"Follow me on Do Good! dogood://users/%@\n\n---\nDon't have Do Good? Get it from the App Store: https://get.dogood.co", [DGUser currentUser].userID];
    
	[_parent presentViewController:picker animated:YES completion:NULL];
}

#pragma mark - MessageUI Delegate Methods
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error {
	// Notifies users about errors associated with the interface
    NSString *feedbackMsg;
	switch (result) {
		case MFMailComposeResultCancelled:
			feedbackMsg = @"Result: Mail sending canceled";
			break;
		case MFMailComposeResultSaved:
			feedbackMsg = @"Result: Mail saved";
			break;
		case MFMailComposeResultSent:
			feedbackMsg = @"Result: Mail sent";
			break;
		case MFMailComposeResultFailed:
			feedbackMsg = @"Result: Mail sending failed";
			break;
		default:
			feedbackMsg = @"Result: Mail not sent";
			break;
	}
    DebugLog(@"%@", feedbackMsg);
    
	[_parent dismissViewControllerAnimated:YES completion:NULL];
}

- (void)messageComposeViewController:(MFMessageComposeViewController *)controller didFinishWithResult:(MessageComposeResult)result {
    NSString *feedbackMsg;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MessageComposeResultCancelled:
			feedbackMsg = @"Result: SMS sending canceled";
			break;
		case MessageComposeResultSent:
			feedbackMsg = @"Result: SMS sent";
			break;
		case MessageComposeResultFailed:
			feedbackMsg = @"Result: SMS sending failed";
			break;
		default:
			feedbackMsg = @"Result: SMS not sent";
			break;
	}
    DebugLog(@"%@", feedbackMsg);

	[self dismissViewControllerAnimated:YES completion:NULL];
}

@end