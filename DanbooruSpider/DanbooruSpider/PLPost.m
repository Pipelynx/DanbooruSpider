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
        neverUpdated = YES;
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
    neverUpdated = NO;
    _source = [NSString stringWithContentsOfURL:[self URL] encoding:NSUTF8StringEncoding error:nil];
    return;
}
- (NSString*)ratingWithDocument:(TFHpple*)doc {
    NSArray* elements = [doc searchWithXPathQuery:@"//li[starts-with(text(),\"Rating:\")]"];
    TFHppleElement* e = [elements objectAtIndex:0];
    return [[e content] stringByReplacingOccurrencesOfString:@"Rating: " withString:@""];
}
- (NSDecimalNumber*)voteAverageWithDocument:(TFHpple*)doc {
    NSDecimalNumber* voteAverage;
    NSArray* elements = [doc searchWithXPathQuery:@"//li/span"];
    TFHppleElement* e;
    for (int i = 0; i < [elements count]; i++) {
        e = [elements objectAtIndex:i];
        if ([[[e attributes] objectForKey:@"id"] hasPrefix:@"post-score"]) {
            voteAverage = [NSDecimalNumber decimalNumberWithString:[e content]];
        }
    }
    return voteAverage;
}

- (void)previousPost {
    [self previousPostAndUpdate:NO];
}
- (void)previousPostAndUpdate:(BOOL)update {
    [self setPostNumber:(_postNumber - 1) andUpdate:update];
    if (update)
        [self updateCache];
}
- (void)nextPost {
    [self nextPostAndUpdate:NO];
}
- (void)nextPostAndUpdate:(BOOL)update {
    [self setPostNumber:(_postNumber + 1) andUpdate:update];
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[Post %ld] %@", _postNumber, [[[[self originalImageURL] absoluteString] pathComponents] lastObject]];
}

- (PLPage*)page {
    return _page;
}
- (void)setPage:(PLPage*)newPage {
    _page = newPage;
}

- (NSURL*)URL {
    return [[_page URL] URLByAppendingPathComponent:[NSString stringWithFormat:@"post/show/%ld", _postNumber ]];
}
- (NSString*)fileName {
    if (neverUpdated)
        [self updateCache];
    return [NSString stringWithFormat:@"%ld.%@", _postNumber, [[[self originalImageURL] absoluteString] pathExtension]];
}
- (NSInteger)postNumber {
    return _postNumber;
}
- (void)setPostNumber:(NSInteger)newPostNumber {
    [self setPostNumber:newPostNumber andUpdate:NO];
}
- (void)setPostNumber:(NSInteger)newPostNumber andUpdate:(BOOL)update {
    _postNumber = newPostNumber;
    neverUpdated = YES;
    if (update)
        [self updateCache];
}

- (BOOL)postExists {
    if (neverUpdated)
        [self updateCache];
    return [_source postExists];
}
- (NSURL*)originalImageURL {
    if (neverUpdated)
        [self updateCache];
    return [properties valueForKey:@"original"];
}
- (NSData*)originalImageData {
    return [NSData dataWithContentsOfURL:[self originalImageURL]];
}
- (NSURL*)PNGImageURL {
    if (neverUpdated)
        [self updateCache];
    return [properties valueForKey:@"png"];
}
- (NSData*)PNGImageData {
    return [NSData dataWithContentsOfURL:[self PNGImageURL]];
}
- (NSArray*)tags {
    if (neverUpdated)
        [self updateCache];
    return [properties valueForKey:@"tags"];
}
- (NSDecimalNumber*)voteAverage {
    if (neverUpdated)
        [self updateCache];
    return [properties valueForKey:@"vote average"];
}
- (NSString*)rating {
    if (neverUpdated)
        [self updateCache];
    return [properties valueForKey:@"rating"];
}

@end
