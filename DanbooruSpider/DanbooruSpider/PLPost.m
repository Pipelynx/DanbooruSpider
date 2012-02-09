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
    _postNumber--;
}
- (void)nextPost {
    _postNumber++;
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

- (NSInteger)postNumber {
    return _postNumber;
}
- (void)setPostNumber:(NSInteger)newPostNumber {
    _postNumber = newPostNumber;
}

- (NSURL*)originalImageURL {
    return [properties valueForKey:@"original"];
}
- (NSData*)originalImageData {
    return [NSData dataWithContentsOfURL:[self originalImageURL]];
}
- (NSURL*)PNGImageURL {
    return [properties valueForKey:@"png"];
}
- (NSData*)PNGImageData {
    return [NSData dataWithContentsOfURL:[self PNGImageURL]];
}
- (NSArray*)tags {
    return [properties valueForKey:@"tags"];
}
- (NSDecimalNumber*)voteAverage {
    return [properties valueForKey:@"vote average"];
}
- (NSString*)rating {
    return [properties valueForKey:@"rating"];
}

@end
