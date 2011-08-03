#import "UIViewController+Spinner.h"

static UIImageView *spinnerImageView = NULL;

@implementation UIViewController(Spinner)

//@synthesize spinnerImageView;

- (void) showSpinner {
	
	if(!spinnerImageView) {
		spinnerImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"bg-spinner.png"]];
		UIActivityIndicatorView *spinner = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
		[spinnerImageView addSubview:spinner];
		
		
		CGRect spinnerImageViewRect = spinnerImageView.frame;
		CGRect spinnerRect = spinner.frame;
		CGSize screenSize = [[UIScreen mainScreen] bounds].size;
		
		// Center spinner inside bg
		spinnerRect.origin.x = spinnerImageViewRect.size.width/2-spinnerRect.size.width/2;
		spinnerRect.origin.y = spinnerImageViewRect.size.height/2-spinnerRect.size.height/2;
		spinner.frame = spinnerRect;
		
		// Center bg inside topview
		spinnerImageViewRect.origin.x = screenSize.width/2-spinnerImageViewRect.size.width/2;
		spinnerImageViewRect.origin.y = screenSize.height/2-spinnerImageViewRect.size.height/2-64;
		spinnerImageView.frame = spinnerImageViewRect;

		[spinner startAnimating];
		[spinner release];
		[self.view addSubview:spinnerImageView];
		
	}
	//[UIView beginAnimations:@"animateAdBannerOn" context:NULL];
	[UIView animateWithDuration:1.5 animations:^{spinnerImageView.alpha = 1;}];
	
	//[UIView commitAnimations];
}
- (void) hideSpinner {
	if(spinnerImageView) {
		if (spinnerImageView.alpha != 0) {
			[UIView animateWithDuration:1.5 animations:^{spinnerImageView.alpha = 0;}];
		}
	}
}

@end
