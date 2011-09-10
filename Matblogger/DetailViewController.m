//
//  DetailViewController.m
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 01.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "DetailViewController.h"
#import "CustomNavigationBar.h"

@interface DetailViewController ()
- (void) drawWebView:(FeedItem *)item;
- (void)visitInBrowser;
- (void)sendemail;
-(void)displayComposerSheet;
-(void)launchMailAppOnDevice;

@end

@implementation DetailViewController

@synthesize selectedItem,webView,request_open_url;
@synthesize toolbar=_toolbar,homeBtn,favBtn,actionBtn;
@synthesize service, context,fromFavorite;

- (void)dealloc
{
    [selectedItem release];
    [webView release];
    [request_open_url release];
    [_toolbar release];
    [logoView release];
    [context release];
    [service release];
    [homeBtn release];
    [favBtn release];
    [actionBtn release];
    [super dealloc];
}

- (void)viewDidLoad
{
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
    UIImageView *bgView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg.png"]] autorelease];
    CGRect orgFrame = CGRectMake(0, 0, 1000, self.toolbar.frame.size.height);
    bgView.frame = orgFrame;
    logoView = [[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"matblogger.png"]] autorelease];
    orgFrame = CGRectMake(self.toolbar.frame.size.width/2-67, (self.toolbar.frame.size.height/2)-17, 134, 34);
    logoView.frame = orgFrame;
    [self.toolbar addSubview:bgView];
    [self.toolbar addSubview:logoView];
        self.webView.backgroundColor = self.view.backgroundColor = UIColorFromRGB(0x333333);
    } else {
        UIImage* titleImage = [UIImage imageNamed:@"matblogger.png"];
        UIView* titleView = [[UIImageView alloc] initWithFrame:CGRectMake(0,0,titleImage.size.width, self.navigationController.navigationBar.frame.size.height)];
        UIImageView* titleImageView = [[UIImageView alloc] initWithImage:titleImage];
        [titleView addSubview:titleImageView];
        titleImageView.center = titleView.center;
        CGRect titleImageViewFrame = titleImageView.frame;
        // Offset the logo up a bit
        titleImageViewFrame.origin.y = titleImageViewFrame.origin.y + 3.0;
        titleImageView.frame = titleImageViewFrame;
        self.navigationItem.titleView = titleView;
        [titleImageView release];
        self.webView.backgroundColor = self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
    }
    [super viewDidLoad];

    self.webView.scalesPageToFit = YES;
    self.webView.delegate = self;
    
    
    
    if(self.selectedItem) {
        [self drawWebView:self.selectedItem];
    } else {
        [self home:self];

    }
    service = [LOStorageService instance];
	context = [service managedObjectContext];
}

- (void) setSelectedItem:(FeedItem *)item {
    if(item != nil) {
        self.homeBtn.enabled = self.favBtn.enabled = self.actionBtn.enabled = YES;
    } else {
        self.homeBtn.enabled = self.favBtn.enabled = self.actionBtn.enabled = NO;
    }
    if(self.fromFavorite)
        self.favBtn.enabled = NO;
    if(item != selectedItem){
        [selectedItem release];
        selectedItem = [item retain];
        [self drawWebView:item];
    } 
}

- (void) drawWebView:(FeedItem *)item {
    
    NSString *header = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pre" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [NSString stringWithFormat:@"<h1>%@<span class='blog-url'>%@</span></h1><div class='m-cont' id='cont'>%@</div>",item.title, item.url,item.body];
    NSString *footer = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *doc = [NSString stringWithFormat:@"%@%@%@",header,content,footer];
    
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [self.webView loadHTMLString:doc baseURL:[NSURL URLWithString:
                                              [NSString stringWithFormat:@"file:/%@//", resourcePath]]];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	
	if(buttonIndex == 0) {
		[[UIApplication sharedApplication] openURL:self.request_open_url];
    }
}

- (void)visitInBrowser {
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Vis i nettleser" message: @"Vis du se artikkelen i nettleseren?" delegate:self cancelButtonTitle: @"Jepp" otherButtonTitles:@"Nei", nil];
    self.request_open_url = [NSURL URLWithString:selectedItem.url];
    [someError show];
    [someError release];
}

- (IBAction)favorit:(id)sender {
    //[self.selectedItem setValue:[NSNumber numberWithBool:YES] forKey:@"favorite"];
    [self.selectedItem addToContext:context];
    [service save];
    self.favBtn.enabled = NO;
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Lagt til i favoritter" message: @"Artikkelen er lagt til i favoritter" delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
    [someError show];
    [someError release];
}
- (IBAction)openURL:(id)sender {
    [self visitInBrowser];
}
- (IBAction)home:(id)sender {
    self.selectedItem = nil;
    NSString *header = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"pre" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *content = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"start" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *footer = [NSString stringWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"post" ofType:@"html"] encoding:NSUTF8StringEncoding error:nil];
    NSString *doc = [NSString stringWithFormat:@"%@%@%@",header,content,footer];
    
    NSString *resourcePath = [[[[NSBundle mainBundle] resourcePath]
                               stringByReplacingOccurrencesOfString:@"/" withString:@"//"]
                              stringByReplacingOccurrencesOfString:@" " withString:@"%20"];
    [self.webView loadHTMLString:doc baseURL:[NSURL URLWithString:
                                              [NSString stringWithFormat:@"file:/%@//", resourcePath]]];
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    //NSLog(@"loading url: %@", [[request URL] fragment]);
    if ([[[request URL] scheme] isEqualToString: @"file"] && [self respondsToSelector: NSSelectorFromString([[request URL] fragment])]) {
        [self performSelector: NSSelectorFromString([[request URL] fragment])];
        return NO;
    }
    if([[request URL] host]) {
        self.request_open_url = [request URL];
        UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Vis i nettleser" message: @"Vis gå til denne lenken i nettleseren?" delegate:self cancelButtonTitle: @"Jepp" otherButtonTitles:@"Nei", nil];
        [someError show];
        [someError release];
        return NO;
    } else {
        return YES;
    }
}


#pragma mark - Split view support

- (void)splitViewController:(UISplitViewController *)svc willHideViewController:(UIViewController *)aViewController withBarButtonItem:(UIBarButtonItem *)barButtonItem forPopoverController: (UIPopoverController *)pc
{
    barButtonItem.title = @"Matblogger";
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items insertObject:barButtonItem atIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    logoView.hidden = NO;
}

// Called when the view is shown again in the split view, invalidating the button and popover controller.
- (void)splitViewController:(UISplitViewController *)svc willShowViewController:(UIViewController *)aViewController invalidatingBarButtonItem:(UIBarButtonItem *)barButtonItem
{
    NSMutableArray *items = [[self.toolbar items] mutableCopy];
    [items removeObjectAtIndex:0];
    [self.toolbar setItems:items animated:YES];
    [items release];
    logoView.hidden = YES;
}
- (void)sendemail {
    Class mailClass = (NSClassFromString(@"MFMailComposeViewController"));
	if (mailClass != nil)
	{
		// We must always check whether the current device is configured for sending emails
		if ([mailClass canSendMail])
		{
			[self displayComposerSheet];
		}
		else
		{
			[self launchMailAppOnDevice];
		}
	}
	else
	{
		[self launchMailAppOnDevice];
	}
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
}

#pragma mark -
#pragma mark Compose Mail

// Displays an email composition interface inside the application. Populates all the Mail fields. 
-(void)displayComposerSheet 
{
	MFMailComposeViewController *picker = [[MFMailComposeViewController alloc] init];
	picker.mailComposeDelegate = self;
	[picker setSubject:@"Tilbakemeldinger på Matblogger"];
	[picker setToRecipients:[NSArray arrayWithObject:@"matblogger@gersh.no"]];
	[self presentModalViewController:picker animated:YES];
    [picker release];
}


// Dismisses the email composition interface when users tap Cancel or Send. Proceeds to update the message field with the result of the operation.
- (void)mailComposeController:(MFMailComposeViewController*)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError*)error 
{	
	NSString *message;
	// Notifies users about errors associated with the interface
	switch (result)
	{
		case MFMailComposeResultCancelled:
			message = @"Beskjeden ble avbrutt";
			break;
		case MFMailComposeResultSaved:
			message = @"Beskjeden ble lagret";
			break;
		case MFMailComposeResultSent:
			message = @"Beskjeden ble sendt";
			break;
		default:
			message = @"Beskjeden ble ikke sendt";
			break;
	}
	[self dismissModalViewControllerAnimated:YES];
    UIAlertView *someError = [[UIAlertView alloc] initWithTitle: @"Tilbakemelding på Matblogger" message:message delegate:nil cancelButtonTitle: @"OK" otherButtonTitles:nil];
    [someError show];
    [someError release];
}


#pragma mark -
#pragma mark Workaround

// Launches the Mail application on the device.
-(void)launchMailAppOnDevice
{
	NSString *recipients = @"mailto:matblogger@gersh.no?subject=Tilbakemeldinger på Matblogger";
	
	NSString *email = [NSString stringWithFormat:@"%@", recipients];
	email = [email stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
	
	[[UIApplication sharedApplication] openURL:[NSURL URLWithString:email]];
}

@end
