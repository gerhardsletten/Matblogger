//
//  FavoritesViewController.m
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 13.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FavoritesViewController.h"


@implementation FavoritesViewController

@synthesize service, context;

- (void)dealloc
{
    [super dealloc];
    [service release];
    [context release];
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.navigationItem.rightBarButtonItem = self.editButtonItem;
    // Custom title..
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 320, 320 / 11)];
    //label.font = 16.0;
    label.font = [UIFont boldSystemFontOfSize:24];
    label.textColor = UIColorFromRGB(0x2799E0);
    label.shadowColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
    label.textAlignment = UITextAlignmentCenter;
    label.text = @"Favoritter";
    self.navigationItem.titleView = label;
    
    [label release];
    
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:[FeedItem entityName] inManagedObjectContext:context];
    //FeedItem *entity = (FeedItem*)[NSEntityDescription entityForName:@"FeedItem" inManagedObjectContext:context];
	[request setEntity:entity];
	NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"date" ascending:NO];
	NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:sortDescriptor, nil];
	[request setSortDescriptors:sortDescriptors];

	//[sortDescriptors release];
	[sortDescriptor release];
	NSError *error;
	NSArray *mutableFetchResults = [context executeFetchRequest:request error:&error];
	if (mutableFetchResults == nil) {
		// Handle the error.
        [mutableFetchResults release];
	} else {
        self.items = [NSMutableArray arrayWithArray: mutableFetchResults];
    }
	
    [request release];
    
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
		
		cell.detailTextLabel.text = @"Ingen favoritter ennå";
		
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


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
	int count = [items count];
    return count;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
	
    if (editingStyle == UITableViewCellEditingStyleDelete) {
		[tableView  beginUpdates];
        // Delete the managed object at the given index path.
        FeedItem *item = [items objectAtIndex:indexPath.row];
        
		
        // Update the array and table view.
        
        [items removeObjectAtIndex:indexPath.row];
        [context deleteObject:item];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:YES];
		
        // Commit the change.
        NSError *error;
        if (![context save:&error]) {
            // Handle the error.
        }
        [tableView endUpdates];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if([items count] > 0) {
        cell.backgroundColor = UIColorFromRGB(0xffffff);
        cell.textLabel.textColor = UIColorFromRGB(0x189ADB);
    } else {
        cell.textLabel.textColor = UIColorFromRGB(0x189ADB);
    }
    
	cell.detailTextLabel.textColor = UIColorFromRGB(0x474642);
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if([items count] > 0) {
        FeedItem	*item = [items objectAtIndex:indexPath.row];
        [self.tableView reloadRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
        if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
            if(!self.detailViewController) {
                self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
                
            }
            self.detailViewController.fromFavorite = YES;
            if(!self.detailViewController.context)
                self.detailViewController.context = self.context;
            if(!self.detailViewController.service)
                self.detailViewController.service = self.service;
            self.detailViewController.selectedItem = item;
            [self.navigationController pushViewController:self.detailViewController animated:YES];
        } else {
            self.detailViewController.fromFavorite = YES;
            self.detailViewController.selectedItem = item;
            if(!self.detailViewController.context)
                self.detailViewController.context = self.context;
            if(!self.detailViewController.service)
                self.detailViewController.service = self.service;
        }
        
    }
    
}

- (void)appImageDidLoad:(NSIndexPath *)indexPath
{
    [super appImageDidLoad:indexPath];
    // Save new loaded images
    NSError *error;
    if (![context save:&error]) {
        // Handle the error.
    }
}

@end
