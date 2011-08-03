//
//  MatbloggerAppDelegate.m
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MatbloggerAppDelegate.h"
#import "RootViewController.h"
#import "DetailViewController.h"
#import "LOStorageService.h"

@implementation MatbloggerAppDelegate


@synthesize window=_window;
@synthesize rootViewController=_rootViewController;
@synthesize detailViewController=_detailViewController;
@synthesize navigationController,splittViewController;

- (void)dealloc
{
    [_rootViewController release];
    [_detailViewController release];
    [_window release];
    [navigationController release];
    [splittViewController release];
    [super dealloc];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //LOStorageService *service = [LOStorageService instance];
	//[service clearAllData];
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.detailViewController = [[DetailViewController alloc] initWithNibName:@"DetailViewController_iPhone" bundle:nil];
        self.rootViewController.detailViewController = self.detailViewController;
        [self.window addSubview:navigationController.view];
    } else {
        self.splittViewController.delegate = self.detailViewController;
        self.rootViewController.detailViewController = self.detailViewController;
        [self.window addSubview:splittViewController.view];
    }
    
    [self.window makeKeyAndVisible];
    return YES;
}


@end
