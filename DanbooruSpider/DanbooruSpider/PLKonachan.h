//
//  PLKonachan.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLKonachanPost.h"

@interface PLKonachan : PLPage

+ (PLKonachan*)page;

- (PLKonachanPost*)postWithNumber:(NSInteger)postNumber;
- (PLKonachanPost*)newestPost;

@end
