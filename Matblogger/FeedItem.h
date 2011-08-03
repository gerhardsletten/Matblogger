//
//  FeedItem.h
//  Matblogger
//
//  Created by Eyvind Gerhard Sletten on 16.07.11.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface FeedItem : NSManagedObject {
@private
}
@property (nonatomic, retain) NSString * title;
@property (nonatomic, retain) NSString * desc;
@property (nonatomic, retain) NSString * body;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSData * img;
@property (nonatomic, retain) NSData * preview;
@property (nonatomic, retain) NSString * imageUrl;
@property (nonatomic, retain) NSString * url;
@property (nonatomic, retain) NSNumber * read;
@property (nonatomic, retain) NSNumber * favorite;

- (UIImage *)thumbnailOfSize:(CGSize)size;

+ (NSString *)entityName;
+ (id)disconnectedEntity;
- (void)addToContext:(NSManagedObjectContext *)context;

@end
