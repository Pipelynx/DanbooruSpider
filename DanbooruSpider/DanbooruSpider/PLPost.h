//
//  PLPost.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>

@class PLPage;

@interface PLPost : NSObject {
    NSMutableDictionary* properties;
    __weak PLPage* _page;
    BOOL neverUpdated;
    NSInteger _postNumber;
    NSString* _source;
}

+ (PLPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage;

- (void)updateCache;
- (NSString*)ratingWithDocument:(TFHpple*)doc;
- (NSDecimalNumber*)voteAverageWithDocument:(TFHpple*)doc;
- (void)previousPost;
- (void)previousPostAndUpdate:(BOOL)update;
- (void)nextPost;
- (void)nextPostAndUpdate:(BOOL)update;

- (PLPage*)page;
- (void)setPage:(PLPage*)newPage;

- (NSURL*)URL;

- (NSInteger)postNumber;
- (void)setPostNumber:(NSInteger)newPostNumber;
- (void)setPostNumber:(NSInteger)newPostNumber andUpdate:(BOOL)update;

- (BOOL)postExists;
- (NSString*)fileName;
- (NSURL*)originalImageURL;
- (NSData*)originalImageData;
- (NSURL*)PNGImageURL;
- (NSData*)PNGImageData;
- (NSArray*)tags;
- (NSDecimalNumber*)voteAverage;
- (NSString*)rating;
@end
