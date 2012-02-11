//
//  main.m
//  DanbooruSpiderCLI
//
//  Created by Martin Fellner on 070212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

BOOL pathContains(NSArray*, NSInteger);

#import "PLSankaku.h"
#import "PLKonachan.h"
#import "PLDonmai.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        NSString* path = [args stringForKey:@"dest"];
        NSInteger from = [args integerForKey:@"from"];
        NSInteger to = [args integerForKey:@"to"];
        NSInteger range = [args integerForKey:@"for"]; 
        
        NSFileManager* fm = [NSFileManager defaultManager];
        PLSankakuPost* post;
        NSString* filePath;
        BOOL isDir;
        
        if (![fm fileExistsAtPath:path isDirectory:&isDir] || !isDir)
            path = [fm currentDirectoryPath];
        fprintf(stdout, "Working directory: %s\n", [path UTF8String]);
        if (from == 0)
            post = [[PLSankaku page] newestPost];
        else
            post = [[PLSankaku page] postWithNumber:from];
        if (range > 0)
            to = [post postNumber] - (range - 1);
        while ([post postNumber] >= to) {
            filePath = [path stringByAppendingPathComponent:[post fileName]];
            fprintf(stdout, "%s", [filePath UTF8String]);
            if (pathContains([fm contentsOfDirectoryAtPath:path error:nil], [post postNumber]))
                fprintf(stdout, " >> exists\n");
            else
                if ([post postExists]) {
                    [[post originalImageData] writeToFile:filePath atomically:YES];
                    fprintf(stdout, " >> downloaded\n");
                }   
                else
                    fprintf(stdout, " >> invalid\n");
            [post previousPost];
        }
    }
    return 0;
}

BOOL pathContains(NSArray* files, NSInteger postNumber) {
    for (NSInteger i = 0; i < [files count]; i++) {
        if ([[files objectAtIndex:i] hasPrefix:[NSString stringWithFormat:@"%ld.", postNumber]])
            return YES;
    }
    return NO;
}