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
    if ([self rangeOfString:@"<p>This post does not exist.</p>"].location == NSNotFound) {
        return YES;
    }
    return NO;
}

@end
