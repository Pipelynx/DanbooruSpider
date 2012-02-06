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
        _type = @"";
        _name = @"";
    }
    return self;
}

+ (PLTag*)tagWithType:(NSString*)aType andName:(NSString*)aName {
    PLTag* temp = [[PLTag alloc] init];
    [temp setType:aType];
    [temp setName:aName];
    return temp;
}

- (NSString*)getType {
    return _type;
}
- (void)setType:(NSString*)newType {
    _type = newType;
}

- (NSString*)getName {
    return _name;
}
- (void)setName:(NSString*)newName {
    _name = newName;
}

- (NSString*)description {
    return [NSString stringWithFormat:@"[%@] %@", _type, _name];
}

@end
