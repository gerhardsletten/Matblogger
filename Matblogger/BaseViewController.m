#import "BaseViewController.h"

@implementation BaseViewController

@synthesize detailViewController=_detailViewController,items,dateFormat;
@synthesize isLandscape,imageDownloadsInProgress;

- (void)dealloc
{
    [super dealloc];
    [_detailViewController release];
    [items release];
    [dateFormat release];
    [imageDownloadsInProgress release];
}

#pragma mark - View lifecycle

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    
    // terminate all pending download connections
    NSArray *allDownloads = [self.imageDownloadsInProgress allValues];
    [allDownloads makeObjectsPerformSelector:@selector(cancelDownload)];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.imageDownloadsInProgress = [NSMutableDictionary dictionary];
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

#pragma mark - Table view data source



#pragma mark - Table view delegate

- (void)startIconDownload:(FeedItem *)appRecord forIndexPath:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = nil;
    if (iconDownloader == nil) 
    {
        iconDownloader = [[IconDownloader alloc] init];
        iconDownloader.appRecord = appRecord;
        iconDownloader.indexPathInTableView = indexPath;
        iconDownloader.delegate = self;
        [imageDownloadsInProgress setObject:iconDownloader forKey:indexPath];
        [iconDownloader startDownload];
        [iconDownloader release];   
    }
}

// this method is used in case the user scrolled into a set of cells that don't have their app icons yet
- (void)loadImagesForOnscreenRows
{
    if ([self.items count] > 0)
    {
        [self.tableView visibleCells];
        NSArray *visiblePaths = [self.tableView indexPathsForVisibleRows];
        for (NSIndexPath *indexPath in visiblePaths)
        {
            FeedItem *item = [self.items objectAtIndex:indexPath.row];
            if (!item.img && item.imageUrl) // avoid the app icon download if the app already has an icon
            {
                [self startIconDownload:item forIndexPath:indexPath];
				
            } 
        }
    }
}

// called by our ImageDownloader when an icon is ready to be displayed
- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    IconDownloader *iconDownloader = [imageDownloadsInProgress objectForKey:indexPath];
    if (iconDownloader != nil)
    {
        UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:iconDownloader.indexPathInTableView];
        
        // Display the newly loaded image
		FeedItem	*item = [items objectAtIndex:iconDownloader.indexPathInTableView.row];
		CGRect img_frame = cell.imageView.frame;
		img_frame.size.width = img_frame.size.height;
		cell.imageView.image = [item thumbnailOfSize:img_frame.size];
    }
}


#pragma mark -
#pragma mark Deferred image loading (UIScrollViewDelegate)

// Load images for all onscreen rows when scrolling is finished
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if (!decelerate)
	{
        [self loadImagesForOnscreenRows];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    [self loadImagesForOnscreenRows];
}


@end
