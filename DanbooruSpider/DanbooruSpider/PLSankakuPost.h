//
//  PLSankakuPost.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPost.h"

#import "PLTag.h"

@interface PLSankakuPost : PLPost

+ (PLSankakuPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage;

@end
