//
//  PLSankaku.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLSankaku.h"

@implementation PLSankaku

+ (PLSankaku*)page {
    PLSankaku* temp = [[PLSankaku alloc] init];
    [temp setURL:[NSURL URLWithString:@"http://chan.sankakucomplex.com"]];
    [temp updateCache];
    return temp;
}

- (void)updateCache {
    NSString* home = [NSString stringWithContentsOfURL:[_url URLByAppendingPathComponent:@"post"] encoding:NSUTF8StringEncoding error:nil];
    TFHpple* doc = [[TFHpple alloc] initWithHTMLData:[home dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray* elements = [doc searchWithXPathQuery:@"//a/@href"];
    NSString* content;
    NSInteger newestPostNumber = [[properties objectForKey:@"newestPostNumber"] integerValue];
    NSInteger h;
    for (int i = 0; i < [elements count]; i++) {
        content = [[elements objectAtIndex:i] content];
        if ([content hasPrefix:@"/post/show/"]) {
            content = [[content componentsSeparatedByString:@"/"] objectAtIndex:3];
            h = [content integerValue];
            if (h > newestPostNumber)
                newestPostNumber = h;
        }
    }
    [properties setValue:[NSString stringWithFormat:@"%u", newestPostNumber] forKey:@"newestPostNumber"];
}

- (PLSankakuPost*)postWithNumber:(NSInteger)postNumber {
    __weak PLSankakuPost* post = [PLSankakuPost postWithNumber:postNumber andPage:self];
    [post updateCache];
    return post;
}

- (PLSankakuPost*)newestPost {
    return [self postWithNumber:[self newestPostNumber]];
}

@end
