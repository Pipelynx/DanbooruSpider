//
//  PLPost.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLPost.h"

@implementation PLPost

- (id)init {
    if ([super init]) {
        properties = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:[NSURL URLWithString:@""], [NSURL URLWithString:@""], [NSArray array], [NSDecimalNumber decimalNumberWithString:@"0.0"], @"", nil]
                                                        forKeys:[NSArray arrayWithObjects:@"original", @"png", @"tags", @"vote average", @"rating", nil]];
        _page = nil;
        _postNumber = 0;
    }
    return self;
}

+ (PLPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage {
    PLPost* temp = [[PLPost alloc] init];
    [temp setPostNumber:postNumber];
    [temp setPage:aPage];
    return temp;
}

- (void)updateCache {
    return;
}

- (PLPage*)getPage {
    return _page;
}
- (void)setPage:(PLPage*)newPage {
    _page = newPage;
}

- (NSURL*)getURL {
    return _url;
}
- (void)setURL:(NSURL*)newURL {
    _url = newURL;
}

- (NSInteger)getPostNumber {
    return _postNumber;
}
- (void)setPostNumber:(NSInteger)newPostNumber {
    _postNumber = newPostNumber;
}

- (NSURL*)getOriginalImageURL {
    return [properties valueForKey:@"original"];
}
- (NSData*)getOriginalImageData {
    return [NSData dataWithContentsOfURL:[self getOriginalImageURL]];
}
- (NSURL*)getPNGImageURL {
    return [properties valueForKey:@"png"];
}
- (NSData*)getPNGImageData {
    return [NSData dataWithContentsOfURL:[self getPNGImageURL]];
}
- (NSArray*)getTags {
    return [properties valueForKey:@"tags"];
}
- (NSDecimalNumber*)getVoteAverage {
    return [properties valueForKey:@"vote average"];
}
- (NSString*)getRating {
    return [properties valueForKey:@"rating"];
}

@end
