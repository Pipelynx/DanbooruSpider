//
//  PLPage.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 040212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TFHpple.h"

#import "NSURL+Checks.h"

#import "PLPost.h"

@interface PLPage : NSObject {
    NSMutableDictionary* properties;
    NSURL* _url;
}

+ (PLPage*)page;

- (void)updateCache;
- (PLPost*)postWithNumber:(NSInteger)postNumber;
- (PLPost*)newestPost;

- (NSURL*)URL;
- (void)setURL:(NSURL*)newURL;

- (NSInteger)newestPostNumber;
@end
