//
//  PLDonmaiPost.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPost.h"

#import "PLTag.h"

@interface PLDonmaiPost : PLPost

+ (PLDonmaiPost*)postWithNumber:(NSInteger)postNumber andPage:(PLPage*)aPage;

@end
