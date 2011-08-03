//
//  LOStorageService.m
//  TemporaryCoreData
//
//  Created by Locassa on 22/05/2011.
//  Copyright 2011 Locassa Ltd. All rights reserved.
//

#import "LOStorageService.h"


@interface LOStorageService (private)

- (NSManagedObjectModel *)managedObjectModel;
- (NSPersistentStoreCoordinator *)persistentStoreCoordinator;

@end

@implementation LOStorageService

#define kIdentifier @"CoreDataDemo"

static LOStorageService *instance = nil;

#pragma mark -
#pragma mark Singleton Methods

+ (LOStorageService *) instance {
    @synchronized(self) {
        if (instance == nil) {
			instance = [[LOStorageService alloc] initWithIdentifier:kIdentifier];
		}
    }	
    return instance;
}

+ (id)allocWithZone:(NSZone *)zone {
    @synchronized(self) {
        if (instance == nil) {
            instance = [super allocWithZone:zone];
            return instance;  // assignment and return on first allocation
        }
    }
	
    return nil; // on subsequent allocation attempts return nil
}

- (id)copyWithZone:(NSZone *)zone {
    return self;
}

- (id)retain {
    return self;
}

- (unsigned)retainCount {
    return UINT_MAX;  // denotes an object that cannot be released
}

- (void)release {
    //do nothing
}

- (id)autorelease {
    return self;
}

#pragma mark -
#pragma mark Instance Methods

- (id) initWithIdentifier:(NSString *)anIdentifier {
	self = [super init];
	
	if(self != nil) {
		identifier = anIdentifier;
	}
	
	return self;
}

- (void) dealloc {    
    [managedObjectContext release];
    [managedObjectModel release];
    [persistentStoreCoordinator release];
	[identifier release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Core Data stack

- (NSManagedObjectContext *) managedObjectContext {    
    if (managedObjectContext != nil) {
        return managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];

    if (coordinator != nil) {
        managedObjectContext = [[NSManagedObjectContext alloc] init];
        [managedObjectContext setPersistentStoreCoordinator:coordinator];
    }
	
    return managedObjectContext;
}

- (NSManagedObjectModel *)managedObjectModel {    
    if (managedObjectModel != nil) {
        return managedObjectModel;
    }
	
	//NSString *modelPath = [[NSBundle mainBundle] pathForResource:identifier ofType:@"mom"];
    //NSURL *modelURL = [NSURL fileURLWithPath:modelPath];
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Matblogger" withExtension:@"momd"];
	
    managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];    
    return managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {    
    if (persistentStoreCoordinator != nil) {
        return persistentStoreCoordinator;
    }
    
	NSString *storeFilename = [[NSString alloc] initWithFormat:@"%@.sqlite", identifier];
    NSString *storePath = [[self applicationDocumentsDirectoryPath] stringByAppendingPathComponent:storeFilename];
	NSURL *storeURL = [NSURL fileURLWithPath:storePath];
    [storeFilename release];
	
    NSError *error = nil;
    persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    
	if (![persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
		return nil;
    }    
    
    return persistentStoreCoordinator;
}

#pragma mark -
#pragma mark Data Methods

- (void) deleteAllObjects: (NSString *) entityDescription  {
	NSManagedObjectContext *context = [self managedObjectContext];
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:entityDescription inManagedObjectContext:context];
    [fetchRequest setEntity:entity];
	
    NSError *error;
    NSArray *items = [context executeFetchRequest:fetchRequest error:&error];
    [fetchRequest release];
		
    for (NSManagedObject *managedObject in items) {
        [context deleteObject:managedObject];
        NSLog(@"%@ object deleted", entityDescription);
    }
	
    [self save];
}

- (BOOL)save {
	NSError *error;
	
    if (![managedObjectContext save:&error]) {
        [self logNSError:error];
		return FALSE;
    }	
	
	return TRUE;
}

- (void)clearAllData {
	[self deleteAllObjects:[FeedItem entityName]];
	//[self deleteAllObjects:[LOAddress entityName]];
}

- (NSArray *)allObjectsOfType:(Class)class {
	NSManagedObjectContext *context = [self managedObjectContext];
	
	NSFetchRequest *request = [[NSFetchRequest alloc] init];
	NSEntityDescription *entity = [NSEntityDescription entityForName:[class entityName] inManagedObjectContext:context];
	[request setEntity:entity];
	
	NSError *error = nil;
	NSArray *fetchResults = [context executeFetchRequest:request error:&error];
	[request release];
	
	if (error != nil) {
		NSLog(@"There was an error retrieving all objects of type: %@, %@", NSStringFromClass(class), [error localizedDescription]);
		[self logNSError:error];
		return nil;
	}
	
	return fetchResults;	
}

#pragma mark -
#pragma mark Helper Methods

- (NSString *)applicationDocumentsDirectoryPath {
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	return [paths objectAtIndex:0];
}

- (void)logNSError:(NSError *)error {
	NSLog(@"%@", [error userInfo]); 
	
	if([[error userInfo] objectForKey:@"NSDetailedErrors"]) {
		for(NSError *errorItem in [[error userInfo] objectForKey:@"NSDetailedErrors"]) {
			for(NSString *key in [errorItem userInfo]) {
				NSLog(@"%@ - %@", key, [[errorItem userInfo] objectForKey:key]);
			}				
		}
	}
}

@end
