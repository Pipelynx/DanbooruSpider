//
//  PLSankaku.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLSankakuPost.h"

@interface PLSankaku : PLPage

+ (PLSankaku*)page;

- (PLSankakuPost*)postWithNumber:(NSInteger)postNumber;
- (PLSankakuPost*)newestPost;

@end
