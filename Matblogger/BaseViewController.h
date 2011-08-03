//
//  BaseViewController.h
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 14.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#define kCustomRowHeight    60.0
#define kCustomRowCount     7
#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import <UIKit/UIKit.h>
#import <QuartzCore/CALayer.h>
#import "DetailViewController.h"
#import "FeedItem.h"
#import "CustomNavigationBar.h"


@class DetailViewController;

@interface BaseViewController : UITableViewController {
    DetailViewController *detailViewController;
    NSMutableArray *items;
    NSDateFormatter *dateFormat;
    BOOL isLandscape;
    
}
@property (nonatomic, retain) DetailViewController *detailViewController;
@property (nonatomic, retain) NSMutableArray *items;
@property (nonatomic, retain) NSDateFormatter *dateFormat;

@property (nonatomic) BOOL isLandscape;

- (void) goLandscape;
- (void) goPortrait;

@end
