//
//  PLDonmai.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLDonmai.h"

@implementation PLDonmai

+ (PLDonmai*)page {
    PLDonmai* temp = [[PLDonmai alloc] init];
    [temp setURL:[NSURL URLWithString:@"http://danbooru.donmai.us"]];
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

- (PLDonmaiPost*)postWithNumber:(NSInteger)postNumber {
    PLDonmaiPost* post = [PLDonmaiPost postWithNumber:postNumber andPage:self];
    [post updateCache];
    return post;
}

@end
