//
//  FeedItem.m
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 16.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "FeedItem.h"
#import "LOStorageService.h"

@implementation FeedItem
@dynamic title;
@dynamic desc;
@dynamic body;
@dynamic date;
@dynamic img;
@dynamic preview;
@dynamic imageUrl;
@dynamic url;
@dynamic read;
@dynamic favorite;

+ (NSString *)entityName {
    //[self doesNotRecognizeSelector:_cmd];
    //return nil;
    return @"FeedItem";
}

+ (id)disconnectedEntity {
    NSManagedObjectContext *context = [[LOStorageService instance] managedObjectContext];
    NSEntityDescription *entityDescription = [NSEntityDescription entityForName:[self entityName] inManagedObjectContext:context];
    return [[[self alloc] initWithEntity:entityDescription insertIntoManagedObjectContext:nil] autorelease];
}

- (void)addToContext:(NSManagedObjectContext *)context {
    [context insertObject:self];
}

- (UIImage *)thumbnailOfSize:(CGSize)size {
    if( !self.preview ) {
        UIGraphicsBeginImageContext(size);
        
        // draw scaled image into thumbnail context
        UIImage *image = [UIImage imageWithData:self.img];
        [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        
        UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();        
        
        // pop the context
        UIGraphicsEndImageContext();
        
        if(newThumbnail == nil) 
            NSLog(@"could not scale image");
        
        self.preview = UIImageJPEGRepresentation(newThumbnail, 1.0);
        
        
    }
    return [UIImage imageWithData:self.preview];
}

@end
