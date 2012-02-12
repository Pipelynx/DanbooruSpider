//
//  PLTag.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 050212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLTag.h"

@implementation PLTag

- (id)init {
    if (self = [super init]) {
        _category = @"";
        _name = @"";
    }
    return self;
}

+ (PLTag*)tagWithType:(NSString*)aType andName:(NSString*)aName {
    PLTag* temp = [[PLTag alloc] init];
    [temp setCategory:aType];
    [temp setName:aName];
    return temp;
}

- (NSString*)category {
    return _category;
}
- (void)setCategory:(NSString*)newType {
    _category = newType;
}

- (NSString*)name {
    return _name;
}
- (void)setName:(NSString*)newName {
    _name = newName;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@] %@", _category, _name];
}

@end
