#import "RootViewController.h"

@interface RootViewController ()
- (void)showFavorites;

- (void)showMessage:(NSString *)val1 message:(NSString *)val2;
- (void)handleError:(NSError *)error;

- (void) loadMore;
- (void) loadFeed:(NSInteger)page;
- (void) drawFeed;
- (void) refresh:(id)sender;
- (void) showFavorites;

@end

@implementation RootViewController

@synthesize appListFeedConnection, source;

@synthesize service, context;

- (void)dealloc
{
    
	[parser release];
	[source release];
	[appListFeedConnection release];
	[source release];
	[reloadButton release];
    [loadMoreButton release];
    [service release];
    [context release];
    [super dealloc];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];

    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        item_per_page = 10;
    } else {
        item_per_page = 10;
    }
    service = [LOStorageService instance];
	context = [service managedObjectContext];
    
	
    
    reloadButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"reload.png"] style:UIBarButtonItemStylePlain target:self action:@selector(refresh:)];
	self.navigationItem.leftBarButtonItem = reloadButton;
    
    UIBarButtonItem *favButton = [[[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"star.png"] style:UIBarButtonItemStylePlain target:self action:@selector(showFavorites)] autorelease];
    self.navigationItem.rightBarButtonItem = favButton;
    // Custom header
	UIView *containerView = [[[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 50)] autorelease];
	containerView.backgroundColor = UIColorFromRGB(0xf2f2f2);    
    loadMoreButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    /*[loadMoreButton setBackgroundImage:[[UIImage imageNamed:@"button_grey_dark.png"]
                                stretchableImageWithLeftCapWidth:8 topCapHeight:8] forState:UIControlStateNormal];*/
    [loadMoreButton setFrame:CGRectMake(10, 3, 300, 44)];
    [loadMoreButton setTitle:@"Last inn flere" forState:UIControlStateNormal];
    [loadMoreButton.titleLabel setFont:[UIFont boldSystemFontOfSize:20]];
    [loadMoreButton setTitleColor:UIColorFromRGB(0x2799E0) forState:UIControlStateNormal];
    
    //set action of the button
    [loadMoreButton addTarget:self action:@selector(loadMore)
     forControlEvents:UIControlEventTouchUpInside];
	[containerView addSubview:loadMoreButton];
	//self.tableView.tableHeaderView = containerView;
    self.tableView.tableFooterView = containerView;
    
    
    self.loading = NO;
    current_page = 0;
	[self loadFeed:current_page];
}

- (void)showFavorites {
    FavoritesViewController *favoritesController = [[FavoritesViewController alloc] initWithStyle:UITableViewStylePlain];
    favoritesController.detailViewController = self.detailViewController;
    favoritesController.isLandscape = self.isLandscape;
    favoritesController.context = self.context;
    favoritesController.service = self.service;
    [self.navigationController pushViewController:favoritesController animated:YES];
    [favoritesController release];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Loading/displaying feed

- (BOOL) loading {
    return loading;
}

- (void) setLoading:(BOOL)val {
    if(val){
        [self showSpinner];
        reloadButton.enabled = loadMoreButton.enabled =  NO;
        [loadMoreButton setTitle:@"Laster inn.." forState:UIControlStateNormal];
    } else {
        [self hideSpinner];
        reloadButton.enabled = loadMoreButton.enabled = YES;
        [loadMoreButton setTitle:@"Last inn flere" forState:UIControlStateNormal];
    }
    loading = val;
}

- (void) loadMore {
    current_page = current_page + item_per_page;
    [self loadFeed:current_page];
}

- (void) refresh:(id)sender {
    [self loadFeed:0];
    
}

- (void) loadFeed:(NSInteger)page {
    if(!self.loading) {
        self.loading = YES;
        //NSString *loadURL = [NSString stringWithFormat:@"http://localhost/~gerhard/api/matblogger/debug.php?from=%ld&limit=%ld",page, item_per_page];
        NSString *loadURL = [NSString stringWithFormat:@"http://api.gersh.no/matblogger/index.php?from=%ld&limit=%ld",page, item_per_page];
        
        NSURLRequest *urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:loadURL]];
        self.appListFeedConnection = [[[NSURLConnection alloc] initWithRequest:urlRequest delegate:self] autorelease];
        NSAssert(self.appListFeedConnection != nil, @"Failure to create URL connection.");
        [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
    }
}

- (void) drawFeed {
    
    NSString *responseString = [[NSString alloc] initWithData:source encoding:NSUTF8StringEncoding];
	self.source = nil;
    NSDictionary *dict = [responseString JSONValue];
	NSArray *elements = [[dict objectForKey:@"value"] objectForKey:@"items"];
    [responseString release];

    DocumentRoot* document;
	NSDateFormatter *df = [[[NSDateFormatter alloc] init] autorelease];
	[df setDateFormat:@"EEE, dd MMMM yyyy HH:mm:ss Z"];
	[df setLocale:[[[NSLocale alloc] initWithLocaleIdentifier:@"en"] autorelease]];
    
	int new = 0;
	for (NSDictionary* element in elements){
		NSString *link = [element objectForKey:@"link"];
		BOOL exsist = NO;
		for(FeedItem *olditem in items) {
			if([link isEqual:olditem.url]) {
				exsist = YES;
				break;
			}
		}
		if(!exsist) {
            FeedItem *feedItem = [FeedItem disconnectedEntity];
			
            feedItem.title = [element objectForKey:@"title"];
            document = [Element parseHTML:[element objectForKey:@"description"]];
			feedItem.desc = [document contentsText];
            if([element objectForKey:@"content:encoded"]) {
                feedItem.body = [element objectForKey:@"content:encoded"];
            } else {
                feedItem.body = [element objectForKey:@"description"];
            }
            document = [Element parseHTML:feedItem.body];
            Element *img = [document selectElement: @"img"];
            if(img) {
                feedItem.imageUrl = [img attribute:@"src"];
            }
			feedItem.url = link;
			NSDate *date = [df dateFromString:[element objectForKey:@"pubDate"]];
			feedItem.date = date;
            [self.items addObject:feedItem];
			new++;
		} else {
            //[link release];
        }
	}

	if(new == 0) {
		[self showMessage:@"Ingen nye artikler" message:@"Ingen nye artikler har blitt lagt ut siden sist du sjekket"];
	} else {
        NSSortDescriptor * sortByScore = [[[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO] autorelease];
        NSArray * descriptors = [NSArray arrayWithObject:sortByScore];
        self.items = [NSMutableArray arrayWithArray:[self.items sortedArrayUsingDescriptors:descriptors]];
		[self.tableView reloadData];
    }
    self.loading = NO;
}



#pragma mark - NSURLConnection delegate functions

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    self.source = [NSMutableData data];    // start off with new data
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.source appendData:data];  // append incoming data
	
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error {
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
    
    if ([error code] == kCFURLErrorNotConnectedToInternet)
	{
        // if we can identify the error, we can present a more precise message to the user.
        NSDictionary *userInfo = [NSDictionary dictionaryWithObject:@"No Connection Error"
															 forKey:NSLocalizedDescriptionKey];
        NSError *noConnectionError = [NSError errorWithDomain:NSCocoaErrorDomain
														 code:kCFURLErrorNotConnectedToInternet
													 userInfo:userInfo];
        [self handleError:noConnectionError];
    }
	else
	{
        // otherwise handle the error generically
        [self handleError:error];
    }
    self.appListFeedConnection = nil;   // release our connection
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    self.appListFeedConnection = nil;   // release our connection
    
    [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;   
    [self drawFeed];
}

#pragma mark - Table view data source

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
	// customize the appearance of table view cells
	//
	static NSString *CellIdentifier = @"LazyTableCell";
    static NSString *PlaceholderCellIdentifier = @"PlaceholderCell";
    
    // add a placeholder cell while waiting on table data
    int nodeCount = [self.items count];
	
	if (nodeCount == 0 && indexPath.row == 0)
	{
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:PlaceholderCellIdentifier];
        if (cell == nil)
		{
            cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
										   reuseIdentifier:PlaceholderCellIdentifier] autorelease];   
            cell.detailTextLabel.textAlignment = UITextAlignmentCenter;
			cell.selectionStyle = UITableViewCellSelectionStyleNone;
        }
		
		cell.detailTextLabel.text = @"Laster…";
		
		return cell;
    }
	
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil)
	{
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle
									   reuseIdentifier:CellIdentifier] autorelease];
		cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
	
    // Leave cells empty if there's no data yet
    if (nodeCount > 0)
	{
        // Set up the cell...
        FeedItem	*item = [items objectAtIndex:indexPath.row];
        
		cell.textLabel.text = item.title;
		//cell.textLabel.textColor = [UIColor whiteColor];
		if(!self.dateFormat) {
			self.dateFormat = [[NSDateFormatter alloc] init];
			[self.dateFormat setDateStyle:NSDateFormatterShortStyle];
		}
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@: %@",[self.dateFormat stringFromDate:item.date], item.desc];
        cell.imageView.layer.borderWidth = 1.0;
		cell.imageView.layer.borderColor = [[UIColor whiteColor] CGColor];
		cell.imageView.layer.shadowOpacity = 0.3f;
		cell.imageView.layer.shadowOffset = CGSizeZero;
        // Only load cached images; defer new downloads until scrolling ends
        if (!item.img && item.imageUrl)
        {
            if (self.tableView.dragging == NO && self.tableView.decelerating == NO)
            {
                [self startIconDownload:item forIndexPath:indexPath];
            }
            // if a download is deferred or in progress, return a placeholder image
            cell.imageView.image = [UIImage imageNamed:@"Placeholder.png"];  
        }
        else
        {
			CGRect img_frame = cell.imageView.frame;
			img_frame.size.width = img_frame.size.height;
			cell.imageView.image = [item thumbnailOfSize:img_frame.size];
            
        }
		
    }
    
    return cell;
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


#pragma mark - Handling error

- (void)handleError:(NSError *)error
{
    NSString *errorMessage = [error localizedDescription];
	[self showMessage:@"Ingen forbindelse" message:errorMessage];
}

- (void)showMessage:(NSString *)val1 message:(NSString *)val2
{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:val1
														message:val2
													   delegate:nil
											  cancelButtonTitle:@"OK"
											  otherButtonTitles:nil];
    [alertView show];
    [alertView release];
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([items count] > 0) {
        FeedItem	*item = [items objectAtIndex:indexPath.row];
        item.read = [NSNumber numberWithBool:YES];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if(!self.detailViewController) {
                self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
            }
            if(!self.detailViewController.context)
                self.detailViewController.context = self.context;
            if(!self.detailViewController.service)
                self.detailViewController.service = self.service;
            self.detailViewController.selectedItem = item;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        } else {
            self.detailViewController.selectedItem = item;
            if(!self.detailViewController.context)
                self.detailViewController.context = self.context;
            if(!self.detailViewController.service)
                self.detailViewController.service = self.service;
        }
        
    }
    
}




@end
