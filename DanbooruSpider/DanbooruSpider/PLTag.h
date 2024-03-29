//
//  PLTag.h
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PLTag : NSObject {
    NSString* _category;
    NSString* _name;
}

+ (PLTag*)tagWithType:(NSString*)aType andName:(NSString*)aName;

- (NSString*)category;
- (void)setCategory:(NSString*)newType;

- (NSString*)name;
- (void)setName:(NSString*)newName;

@end
