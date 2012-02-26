//
//  NSString+Checks.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "NSString+Checks.h"

@implementation NSString (Checks)

- (BOOL)postExists {
    BOOL result = YES;
    if ([self rangeOfString:@"<p>This post does not exist.</p>"].location != NSNotFound)
        result = NO;
    if ([self rangeOfString:@"This post was deleted."].location != NSNotFound)
        result = NO;
    return result;
}

@end
