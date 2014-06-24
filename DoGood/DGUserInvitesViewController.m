#import "DGUserInvitesViewController.h"
@import MessageUI;

@interface DGUserInvitesViewController () <
    MFMailComposeViewControllerDelegate,
    MFMessageComposeViewControllerDelegate>
@end

@implementation DGUserInvitesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// have pre-canned invites
// setInviteText or setCustomText
// then change names to sendViaText & sendViaEmail
- (void)setInviteText {
    self.isHTML = NO;
    bodyText = [NSString stringWithFormat:@
        "Check out what I'm doing on Do Good! dogood://users/%@\n\n"
        "Use the app to find good things to do and help reward others for their good deeds.\n\n"
        "---\n"
        "Don't have Do Good? Get it from the App Store: http://www.dogood.mobi/",
        [DGUser currentUser].userID];
    subjectText = @"Do Good with me!";
}

- (void)setInviteHTML {
    self.isHTML = YES;
    bodyText = [NSString stringWithFormat:@
        "<p>"
        "Check out what I've been doing on Do Good!<br>"
        "dogood://users/%@"
        "</p>\n"
        "<p>"
        "Use the app to find good things to do and help reward others for their good deeds. "
        "</p>"
        "<p>"
        "---<br>\n"
        "Don't have Do Good?<br>\n"
        "Get it from the App Store: http://www.dogood.mobi/\n\n"
        "</p>"
        "<p>"
        "Cheers,<br>\n"
        "%@\n\n"
        "</p>"
        "<p>"
        "<a href=\"http://www.dogood.mobi/\"><img src=\"http://www.dogood.mobi/images/logos/dg_logo_tiny_green.png\"></a>\n"
        "</p>",
    [DGUser currentUser].userID,
    [DGUser currentUser].full_name];
    subjectText = @"Do Good with me!";
}

- (void)setCustomText:(NSString *)body withSubject:(NSString *)subject {
    bodyText = body;
    subjectText = subject;
}

- (void)setCustomText:(NSString *)body withSubject:(NSString *)subject toRecipient:(NSString *)to {
    recipient = to;
    [self setCustomText:body withSubject:subject];
}

- (IBAction)sendViaText:(id)sender {
    if ([MFMessageComposeViewController canSendText]) {
        [self displaySMSComposerSheet];
    }
    else {
		DebugLog(@"Device not configured to send SMS.");
    }
}

- (IBAction)sendViaEmail:(id)sender {
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
    [picker.navigationBar setTintColor:[UIColor whiteColor]];
	
	[picker setSubject:subjectText];
    if (recipient) {
        [picker setToRecipients:@[ recipient ]];
    }
	
	// Fill out the email body text
	NSString *emailBody = bodyText;
	[picker setMessageBody:emailBody isHTML:self.isHTML];

    [_parent presentViewController:picker animated:YES completion:NULL];
}

- (void)displaySMSComposerSheet {
	MFMessageComposeViewController *picker = [[MFMessageComposeViewController alloc] init];
	picker.messageComposeDelegate = self;
    [picker.navigationBar setTintColor:[UIColor whiteColor]];
	
    picker.body = bodyText;

    if (recipient) {
        [picker setRecipients:@[ recipient ]];
    }
    
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

	[_parent dismissViewControllerAnimated:YES completion:NULL];
}

@end
