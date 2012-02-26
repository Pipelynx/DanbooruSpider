//
//  NSNumber+Formatting.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 150212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSNumber (Formatting)

- (NSString *)humanReadableBase10;
- (NSString *)humanReadableBase2;

@end
