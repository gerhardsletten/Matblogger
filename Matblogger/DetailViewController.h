//
//  DetailViewController.h
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 01.07.11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "FeedItem.h"
#import "LOStorageService.h"
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>

#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface DetailViewController : UIViewController <UIPopoverControllerDelegate, UISplitViewControllerDelegate,UIAlertViewDelegate, UIWebViewDelegate,MFMailComposeViewControllerDelegate> {
    FeedItem *selectedItem;
	UIWebView *webView;
    NSURL *request_open_url;
    UIImageView *logoView;
    LOStorageService *service;
	NSManagedObjectContext *context;
    UIBarButtonItem *homeBtn, *favBtn, *actionBtn;
    BOOL fromFavorite;
}

@property(nonatomic,retain) FeedItem *selectedItem;
@property(nonatomic,retain) IBOutlet UIWebView *webView;
@property(nonatomic,retain) NSURL *request_open_url;

@property(nonatomic) BOOL fromFavorite;

@property (nonatomic, retain) IBOutlet UIToolbar *toolbar;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *homeBtn;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *favBtn;
@property (nonatomic, retain) IBOutlet UIBarButtonItem *actionBtn;

@property (nonatomic, retain) LOStorageService *service;
@property (nonatomic, retain) NSManagedObjectContext *context;

- (IBAction)favorit:(id)sender;
- (IBAction)openURL:(id)sender;
- (IBAction)home:(id)sender;

@end
