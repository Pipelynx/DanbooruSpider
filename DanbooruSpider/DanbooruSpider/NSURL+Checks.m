//
//  NSURL+Checks.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "NSURL+Checks.h"

@implementation NSURL (Checks)

- (BOOL)isSankaku {
    if ([[self host] isEqualToString:@"chan.sankakucomplex.com"])
        return YES;
    return NO;
}
- (BOOL)isKonachan {
    if ([[self host] isEqualToString:@"konachan.com"])
        return YES;
    return NO;
}

@end
