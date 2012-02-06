//
//  PLDonmai.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLPage.h"
#import "PLDonmaiPost.h"

@interface PLDonmai : PLPage

+ (PLDonmai*)page;

- (PLDonmaiPost*)postWithNumber:(NSInteger)postNumber;

@end
