//
//  PLDonmaiPost.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLDonmaiPost.h"

@implementation PLDonmaiPost

+ (PLDonmaiPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage {
    PLDonmaiPost* temp = [[PLDonmaiPost alloc] init];
    [temp setPostNumber:postNumber];
    [temp setPage:aPage];
    [temp setURL:[[aPage getURL] URLByAppendingPathComponent:[NSString stringWithFormat:@"post/show/%ld", postNumber]]];
    return temp;
}

- (void)updateCache {
    NSString* post = [NSString stringWithContentsOfURL:_url encoding:NSUTF8StringEncoding error:nil];
    if ([post rangeOfString:@"<p>This post does not exist.</p>"].location != NSNotFound) {
        return;
    }
    TFHpple* doc = [[TFHpple alloc] initWithHTMLData:[post dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray* elements = [doc searchWithXPathQuery:@"//li/a[@id=\"highres\"]"];
    TFHppleElement* e = [elements objectAtIndex:0];
    [properties setValue:[NSURL URLWithString:[e objectForKey:@"href"]] forKey:@"original"];
    
    elements = [doc searchWithXPathQuery:@"//li/a[@id=\"png\"]"];
    if ([elements count] > 0) {
        e = [elements objectAtIndex:0];
        [properties setValue:[NSURL URLWithString:[e objectForKey:@"href"]] forKey:@"png"];
    }
    
    NSMutableArray* tags = [NSMutableArray array];
    elements = [doc searchWithXPathQuery:@"//li[@class='tag-type-general'] | //li[@class='tag-type-artist'] | //li[@class='tag-type-character'] | //li[@class='tag-type-copyright'] | //li[@class='tag-type-style']"];
    for (int i = 0; i < [elements count]; i++) {
        e = [elements objectAtIndex:i];
        [tags addObject:[PLTag tagWithType:[[[e attributes] objectForKey:@"class"] stringByReplacingOccurrencesOfString:@"tag-type-" withString:@""] andName:[[[e children] objectAtIndex:1] content]]];
    }
    [tags sortUsingComparator:(NSComparator)^(id obj1, id obj2){ return [[obj1 getType] caseInsensitiveCompare:[obj2 getType]]; }];
    [properties setValue:[NSArray arrayWithArray:tags] forKey:@"tags"];
    
    NSDecimalNumber* voteAverage;
    elements = [doc searchWithXPathQuery:@"//li/span"];
    for (int i = 0; i < [elements count]; i++) {
        e = [elements objectAtIndex:i];
        if ([[[e attributes] objectForKey:@"id"] hasPrefix:@"post-score"]) {
            voteAverage = [NSDecimalNumber decimalNumberWithString:[e content]];
        }
    }
    [properties setValue:voteAverage forKey:@"vote average"];
    
    elements = [doc searchWithXPathQuery:@"//li[starts-with(text(),\"Rating:\")]"];
    e = [elements objectAtIndex:0];
    [properties setValue:[[e content] stringByReplacingOccurrencesOfString:@"Rating: " withString:@""] forKey:@"rating"];
}

@end
