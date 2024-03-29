//
//  PLSankakuPost.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLSankakuPost.h"

@implementation PLSankakuPost

+ (PLSankakuPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage {
    PLSankakuPost* temp = [[PLSankakuPost alloc] init];
    [temp setPostNumber:postNumber];
    [temp setPage:aPage];
    return temp;
}

- (void)updateCache {
    [super updateCache];
    if (![_source postExists])
        return;
    
    TFHpple* doc = [[TFHpple alloc] initWithHTMLData:[_source dataUsingEncoding:NSUTF8StringEncoding]];
    NSArray* elements = [doc searchWithXPathQuery:@"//li[starts-with(text(),\"Original\")]/a | //a[starts-with(text(),\"Save this flash\")]"];
    while ([elements count] < 1) {
        [super updateCache];
        if (![_source postExists])
            return;
        elements = [doc searchWithXPathQuery:@"//li[starts-with(text(),\"Original\")]/a | //a[starts-with(text(),\"Save this flash\")]"];
    }
    TFHppleElement* e = [elements objectAtIndex:0];
    [properties setValue:[NSURL URLWithString:[e objectForKey:@"href"]] forKey:@"original"];
    
    NSMutableArray* tags = [NSMutableArray array];
    elements = [doc searchWithXPathQuery:@"//li[@class='tag-type-general'] | //li[@class='tag-type-artist'] | //li[@class='tag-type-character'] | //li[@class='tag-type-copyright']"];
    for (int i = 0; i < [elements count]; i++) {
        e = [elements objectAtIndex:i];
        [tags addObject:[PLTag tagWithType:[[[e attributes] objectForKey:@"class"] stringByReplacingOccurrencesOfString:@"tag-type-" withString:@""] andName:[[e firstChild] content]]];
    }
    [tags sortUsingComparator:(NSComparator)^(id obj1, id obj2){ return [[obj1 category] caseInsensitiveCompare:[obj2 category]]; }];
    [properties setValue:[NSArray arrayWithArray:tags] forKey:@"tags"];
    
    [properties setValue:[self voteAverageWithDocument:doc] forKey:@"vote average"];
    
    [properties setValue:[self ratingWithDocument:doc] forKey:@"rating"];
}

- (NSString*)fileName {
    return [NSString stringWithFormat:@"Sankaku Channel - %@", [super fileName]];
}

@end
