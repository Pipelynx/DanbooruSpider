//
//  main.m
//  DanbooruSpiderCLI
//
//  Created by Martin Fellner on 070212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

BOOL pathContains(NSFileManager*, NSString*, NSInteger);

#import "NSNumber+Formatting.h"

#import "PLSankaku.h"
#import "PLKonachan.h"
#import "PLDonmai.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSFileManager* fm = [NSFileManager defaultManager];
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        NSString* path = [args stringForKey:@"dest"];
        BOOL isDir;
        if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir)
            path = [fm currentDirectoryPath];
        NSInteger from;
        if ([[args stringForKey:@"from"] caseInsensitiveCompare:@"dir"] == NSOrderedSame)
            from = [[path lastPathComponent] integerValue];
        else
            from = [args integerForKey:@"from"];
        NSInteger to = [args integerForKey:@"to"];
        NSInteger range = [args integerForKey:@"for"];
        NSNumberFormatter* f = [[NSNumberFormatter alloc] init];
        [f setNumberStyle:NSNumberFormatterDecimalStyle];
        PLSankakuPost* post;
        NSData* fileData;
        NSString* filePath;
        
        fprintf(stdout, "Working directory: %s\n", [path UTF8String]);
        if (from == 0)
            post = [[PLSankaku page] newestPost];
        else
            post = [[PLSankaku page] postWithNumber:from];
        if (range > 0)
            to = [post postNumber] - (range - 1);
        while ([post postNumber] >= to) {
            if (!pathContains(fm, path, [post postNumber])) {
                filePath = [path stringByAppendingPathComponent:[post fileName]];
                fprintf(stdout, "%s", [filePath UTF8String]);
                if ([post postExists]) {
                    fileData = [post originalImageData];
                    [fileData writeToFile:filePath atomically:YES];
                    fprintf(stdout, " >> %s downloaded\n", [[[NSNumber numberWithUnsignedInteger:[fileData length]] humanReadableBase10] UTF8String]);
                }   
                else
                    fprintf(stdout, " >> invalid\n");
            }
            [post previousPost];
        }
    }
    fprintf(stdout, "Done");
    return 0;
}

BOOL pathContains(NSFileManager* fm, NSString* path, NSInteger postNumber) {
    
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.jpg", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.gif", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.swf", postNumber]]])
        return YES;
    NSArray* files = [fm contentsOfDirectoryAtPath:path error:nil];
    for (NSInteger i = 0; i < [files count]; i++) {
        if ([[files objectAtIndex:i] hasPrefix:[NSString stringWithFormat:@"%ld.", postNumber]])
            return YES;
    }
    return NO;
}