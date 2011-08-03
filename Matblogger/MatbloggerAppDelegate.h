//
//  MatbloggerAppDelegate.h
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 27.06.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
@class RootViewController;
@class DetailViewController;

@interface MatbloggerAppDelegate : NSObject <UIApplicationDelegate> {
    UINavigationController *navigationController;
    UISplitViewController *splittViewController;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;
@property (nonatomic, retain) IBOutlet UISplitViewController *splittViewController;

@property (nonatomic, retain) IBOutlet RootViewController *rootViewController;
@property (nonatomic, retain) IBOutlet DetailViewController *detailViewController;

@end
