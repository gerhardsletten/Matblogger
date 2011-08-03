#import "BaseViewController.h"

#import "Element.h"
#import "DocumentRoot.h"
#import "ElementParser.h"
#import "IconDownloader.h"
#import "JSON.h"
#import <CFNetwork/CFNetwork.h>
#import "UIViewController+Spinner.h"
#import "FavoritesViewController.h"
#import "LOStorageService.h"

@interface RootViewController : BaseViewController <IconDownloaderDelegate,UIScrollViewDelegate> {
    
    ElementParser* parser;
	NSMutableData *source;
	
	NSMutableDictionary *imageDownloadsInProgress;
	NSURLConnection *appListFeedConnection;
	UIBarButtonItem *reloadButton;
    UIButton *loadMoreButton;
    BOOL loading;
    NSInteger current_page;
    NSInteger item_per_page;
    
    LOStorageService *service;
	NSManagedObjectContext *context;
}

@property (nonatomic, retain) NSURLConnection *appListFeedConnection;
@property (nonatomic, retain) NSMutableDictionary *imageDownloadsInProgress;
@property (nonatomic, retain) NSMutableData *source;

@property (nonatomic, retain) LOStorageService *service;
@property (nonatomic, retain) NSManagedObjectContext *context;

@property (nonatomic) BOOL loading;

- (void)appImageDidLoad:(NSIndexPath *)indexPath;

@end
