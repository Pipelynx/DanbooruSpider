//
//  PLAperture.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 310312.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLSankaku.h"
#import "PLKonachan.h"

@interface PLAperture : NSObject

+ (NSArray*)imageVersionsWithContainerName:(NSString*)containerName;
+ (NSString*)scriptForApplyingTagsToPostNumbers:(NSArray*)postNumbers;
+ (NSString*)scriptForSettingTagsForPost:(PLPost*)post;
+ (NSString*)scriptForOperations:(NSString*)operations;
+ (NSString*)scriptForGettingImageVersionsWithContainerName:(NSString*)containerName andOperations:(NSString*)operations;
+ (NSString*)scriptForImportingImagesWithFiles:(NSArray*)files andOperations:(NSString*)operations intoProject:(NSString*)project;

@end
