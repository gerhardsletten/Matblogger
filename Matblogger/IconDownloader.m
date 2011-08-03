
#import "IconDownloader.h"
#import "FeedItem.h"

#define kAppIconHeight 48


@implementation IconDownloader

@synthesize appRecord;
@synthesize indexPathInTableView;
@synthesize delegate;
@synthesize activeDownload;
@synthesize imageConnection;

#pragma mark

- (void)dealloc
{
    [appRecord release];
    [indexPathInTableView release];
    
    [activeDownload release];
    
    [imageConnection cancel];
    [imageConnection release];
    
    [super dealloc];
}

- (void)startDownload
{
    
    if (self.appRecord.imageUrl) {
        self.activeDownload = [NSMutableData data];
        NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:
                                 [NSURLRequest requestWithURL:[NSURL URLWithString:self.appRecord.imageUrl]] delegate:self];
        self.imageConnection = conn;
        [conn release]; 
        
    }
	
}

- (void)cancelDownload
{
    [self.imageConnection cancel];
    self.imageConnection = nil;
    self.activeDownload = nil;
}


#pragma mark -
#pragma mark Download support (NSURLConnectionDelegate)

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data
{
    [self.activeDownload appendData:data];
}

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
	// Clear the activeDownload property to allow later attempts
    self.activeDownload = nil;
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    // Set appIcon and clear temporary data/image
    UIImage *image = [[UIImage alloc] initWithData:self.activeDownload];
    if (image.size.width != kAppIconHeight && image.size.height != kAppIconHeight)
	{
        CGSize itemSize = CGSizeMake(kAppIconHeight, kAppIconHeight);
		UIGraphicsBeginImageContext(itemSize);
		CGRect imageRect = CGRectMake(0.0, 0.0, itemSize.width, itemSize.height);
		[image drawInRect:imageRect];
		
        UIImage *tmpImage = UIGraphicsGetImageFromCurrentImageContext();
        self.appRecord.img =  UIImageJPEGRepresentation(tmpImage, 1.0);
		UIGraphicsEndImageContext();
    }
    else
    {
        self.appRecord.img = UIImageJPEGRepresentation(image, 1.0);
    }
    //self.appRecord.img = UIImageJPEGRepresentation(image, 1.0);
    self.activeDownload = nil;
    [image release];
    
    // Release the connection now that it's finished
    self.imageConnection = nil;
        
    // call our delegate and tell it that our icon is ready for display
    [delegate appImageDidLoad:self.indexPathInTableView];
}

@end

