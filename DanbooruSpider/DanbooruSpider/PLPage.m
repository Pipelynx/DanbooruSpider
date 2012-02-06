//
//  PLPage.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 040212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
@class PLSankaku;

@implementation PLPage

- (id)init {
    if ([super init]) {
        properties = properties = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:@"0", nil]
                                                                     forKeys:[NSArray arrayWithObjects:@"newestPostNumber", nil]];
        _url = nil;
    }
    return self;
}

+ (PLPage*)page {
    return nil;
}

- (void)updateCache {
    return;
}
- (PLPost*)postWithNumber:(NSInteger)postNumber {
    return nil;
}

- (NSURL*)getURL {
    return _url;
}
- (void)setURL:(NSURL*)newURL {
    _url = newURL;
}

- (NSInteger)newestPostNumber {
    return [[properties objectForKey:@"newestPostNumber"] integerValue];
}
@end
