//
//  main.m
//  getSankakuTags
//
//  Created by Martin Fellner on 120212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>

#import "PLSankaku.h"
#import "PLTag.h"

int main (int argc, const char * argv[])
{

    @autoreleasepool {
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        NSInteger postNumber = [[[args stringForKey:@"postNumber"] stringByDeletingPathExtension] integerValue];
        PLSankakuPost* post = [[PLSankaku page] postWithNumber:postNumber];
        NSArray* tags = [post tags];
        PLTag* tag;
        NSMutableString* result = [NSMutableString string];
        for (NSInteger i = 0; i < [tags count]; i++) {
            tag = [tags objectAtIndex:i];
            [result appendFormat:@"%@|%@#", [tag category], [tag name]];
        }
        fprintf(stdout, "%s", [[result substringToIndex:[result length] - 1] UTF8String]);
    }
    return 0;
}

