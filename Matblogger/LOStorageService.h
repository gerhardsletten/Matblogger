//
//  LOStorageService.h
//  TemporaryCoreData
//
//  Created by Locassa on 22/05/2011.
//  Copyright 2011 Locassa Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "FeedItem.h"
//#import "LODomainObject.h"
//#import "LOPerson.h"
//#import "LOAddress.h"

/**
	This class represents a storage service
 */
@interface LOStorageService : NSObject {

@private
	NSString *identifier;	
	NSManagedObjectContext *managedObjectContext;
    NSManagedObjectModel *managedObjectModel;
    NSPersistentStoreCoordinator *persistentStoreCoordinator;	
}

@property (nonatomic, retain, readonly) NSManagedObjectContext *managedObjectContext;

+ (LOStorageService *) instance;

- (id) initWithIdentifier:(NSString *)anIdentifier;
- (NSArray *)allObjectsOfType:(Class)class;
- (BOOL)save;
- (void)clearAllData;

- (NSString *) applicationDocumentsDirectoryPath;
- (void)logNSError:(NSError *)error;

@end
