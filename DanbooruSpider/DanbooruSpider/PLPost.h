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
    PLPage* _page;
    NSURL* _url;
    NSInteger _postNumber;
}

+ (PLPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage;

- (void)updateCache;

- (PLPage*)getPage;
- (void)setPage:(PLPage*)newPage;

- (NSURL*)getURL;
- (void)setURL:(NSURL*)newURL;

- (NSInteger)getPostNumber;
- (void)setPostNumber:(NSInteger)newPostNumber;

- (NSURL*)getOriginalImageURL;
- (NSData*)getOriginalImageData;
- (NSURL*)getPNGImageURL;
- (NSData*)getPNGImageData;
- (NSArray*)getTags;
- (NSDecimalNumber*)getVoteAverage;
- (NSString*)getRating;
@end
