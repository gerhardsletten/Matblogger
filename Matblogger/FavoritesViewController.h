

#import "BaseViewController.h"
#import "LOStorageService.h"

@interface FavoritesViewController : BaseViewController {
    LOStorageService *service;
	NSManagedObjectContext *context;
}

@property (nonatomic, retain) LOStorageService *service;
@property (nonatomic, retain) NSManagedObjectContext *context;

@end
