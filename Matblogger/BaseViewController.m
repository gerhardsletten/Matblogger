#import "BaseViewController.h"

@implementation BaseViewController

@synthesize detailViewController=_detailViewController,items,dateFormat;
@synthesize isLandscape;

- (void)dealloc
{
    [super dealloc];
    [_detailViewController release];
    [items release];
    [dateFormat release];
    
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set the title view to the Instagram logo
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
    
    // Get our custom nav bar
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"bg.png"]];
    
    
    

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.contentSizeForViewInPopover = CGSizeMake(320.0, 600.0);
    } else {
        [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"bg.png"]];
    }
    
    self.title = @"";
    
    // Customize tableview & view
	self.tableView.rowHeight = kCustomRowHeight;
	self.tableView.backgroundView.backgroundColor = self.view.backgroundColor = UIColorFromRGB(0xf2f2f2);
	self.tableView.separatorColor = UIColorFromRGB(0xaaaaaa);
    self.navigationController.navigationBar.barStyle = UIBarStyleBlack;
    
	UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle:@"Tilbake" style:UIBarButtonItemStylePlain target:nil action:nil];
	self.navigationItem.backBarButtonItem = backButton;
	[backButton release];
    
    self.items = [[NSMutableArray alloc] init];
    
}
- (void) goLandscape {
    isLandscape = YES;
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    [customNavigationBar setBackgroundWith:[UIImage imageNamed:@"bg.png"]];
}
- (void) goPortrait {
    isLandscape = NO;
    CustomNavigationBar* customNavigationBar = (CustomNavigationBar*)self.navigationController.navigationBar;
    [customNavigationBar setBackgroundWith:nil];
}
- (void) viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        UIDeviceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
        if(orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
            [self goPortrait];
        } else {
            [self goLandscape];
        }
    }
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return interfaceOrientation == UIInterfaceOrientationPortrait;
    } else {
        return YES;
    }
    
}
- (void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration {
    if([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        if(toInterfaceOrientation == UIInterfaceOrientationPortrait || toInterfaceOrientation == UIInterfaceOrientationPortraitUpsideDown) {
            
            [self goPortrait];
        } else {
            [self goLandscape];
            
        }
    }
    
[super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration ];
}

#pragma mark - Table view data source

// customize the number of rows in the table view
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [items count];
	
	// ff there's no data yet, return enough rows to fill the screen
    if (count == 0)
	{
        return kCustomRowCount;
    }
    return count;
}


-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([items count] > 0) {
        FeedItem	*item = [items objectAtIndex:indexPath.row];
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        if([item.read boolValue]) {
            cell.textLabel.textColor = UIColorFromRGB(0x999999);
        } else {
            cell.textLabel.textColor = UIColorFromRGB(0x189ADB);
        }
        //[item release];
    } else {
        cell.textLabel.textColor = UIColorFromRGB(0x189ADB);
    }
    
	cell.detailTextLabel.textColor = UIColorFromRGB(0x474642);
}




@end
