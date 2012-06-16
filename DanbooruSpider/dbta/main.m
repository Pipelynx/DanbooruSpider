//
//  main.m
//  dbta
//
//  Created by Martin Fellner on 310312.
//  Copyright (c) 2012 VbSKp/AkB. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "/usr/include/sqlite3.h"

#import "PLAperture.h"

BOOL pathContainsPost(NSString* path, NSString* longSite, NSInteger postNumber);
void postDoesNotExist(NSString* path, NSString* longSite, NSInteger postNumber);
void clearMarkers(NSString* path, NSString* longSite, NSInteger postNumber);

int main (int argc, const char * argv[])
{
    
    @autoreleasepool {
        
        PLPage* page = nil;
        PLPost* post = nil;
        NSInteger postNumber;
        NSMutableString* setTags = [NSMutableString string];
        NSString* applyTags;
        NSString* script = nil;
        
        NSUserDefaults* params = [NSUserDefaults standardUserDefaults];
        NSString* site = [params stringForKey:@"site"];
        NSString* tag = [params stringForKey:@"tag"];
        NSString* download = [params stringForKey:@"download"];
        NSString* to = [params stringForKey:@"to"];
        if (to)
            [[NSFileManager defaultManager] createDirectoryAtPath:[to stringByExpandingTildeInPath] withIntermediateDirectories:YES attributes:nil error:nil];
        else
            to = [[NSFileManager defaultManager] currentDirectoryPath];
        
        NSString* longSite = nil;
        if ([site isEqualToString:@"sankaku"]) {
            longSite = @"Sankaku Channel";
            fprintf(stdout, "Getting chan.sankakucomplex.com... ");
            page = [PLSankaku page];
            fprintf(stdout, "done\n");
        }
        if ([site isEqualToString:@"konachan"]) {
            longSite = @"Konachan";
            fprintf(stdout, "Getting konachan.com... ");
            page = [PLKonachan page];
            fprintf(stdout, "done\n");
        }
        
        NSMutableOrderedSet* postNumbers = [NSMutableOrderedSet orderedSet];
        NSString* rangeString;
        if (tag)
            rangeString = tag;
        if (download)
            rangeString = download;
        rangeString = [rangeString stringByReplacingOccurrencesOfString:@"newest" withString:[NSString stringWithFormat:@"%ld", [page newestPostNumber]]];
        NSArray* parts;
        NSInteger x = -1;
        NSInteger y;
        if ([rangeString rangeOfString:@"-"].location != NSNotFound) {
            parts = [rangeString componentsSeparatedByString:@"-"];
            x = [[parts objectAtIndex:0] integerValue];
            y = [[parts objectAtIndex:1] integerValue];
        }
        if ([rangeString rangeOfString:@"+"].location != NSNotFound) {
            parts = [rangeString componentsSeparatedByString:@"+"];
            x = [[parts objectAtIndex:0] integerValue];
            y = x + [[parts objectAtIndex:1] integerValue];
        }
        for (NSInteger i = x; i <= y; i++) {
            [postNumbers addObject:[NSString stringWithFormat:@"%@ - %i", longSite, i]];
        }
        
#pragma mark Tagscript mode
        if (tag && ([site isEqualToString:@"sankaku"] || [site isEqualToString:@"konachan"])) {
            to = [to stringByAppendingPathComponent:@"$start$.applescript"];
            fprintf(stdout, "Saving to file \"%s\"...\n", [[[to stringByExpandingTildeInPath] stringByReplacingOccurrencesOfString:@"$start$" withString:[NSString stringWithFormat:@"%i", x]] UTF8String]);
            if ([postNumbers count] < 1)
                for (NSInteger i = [page newestPostNumber]; i >= 0; i--)
                    [postNumbers addObject:[NSString stringWithFormat:@"%@ - %lu", longSite, i]];
            applyTags = [PLAperture scriptForApplyingTagsToPostNumbers:[postNumbers array]];
            PLPost* post = nil;
            for (NSInteger i = 0; i < [postNumbers count]; i++) {
                parts = [[postNumbers objectAtIndex:i] componentsSeparatedByString:@" - "];
                postNumber = [[parts objectAtIndex:1] integerValue];
                fprintf(stdout, "Appending post %li... ", postNumber);
                post = [page postWithNumber:postNumber];
                [setTags appendString:[PLAperture scriptForSettingTagsForPost:post]];
                fprintf(stdout, "%.2f%% done\n", ((float)i+1.0)/(float)[postNumbers count]*100.0);
                script = [PLAperture scriptForOperations:[NSString stringWithFormat:@"%@\n%@", setTags, applyTags]];
                [script writeToFile:[[to stringByExpandingTildeInPath] stringByReplacingOccurrencesOfString:@"$start$" withString:[NSString stringWithFormat:@"%i", x]] atomically:YES encoding:NSUTF8StringEncoding error:nil];
            }
            fprintf(stdout, "Saved to file %s\n", [[[to stringByExpandingTildeInPath] stringByReplacingOccurrencesOfString:@"$start$" withString:[NSString stringWithFormat:@"%i", x]] UTF8String]);
        }
        
#pragma mark Download mode
        if (download && ([site isEqualToString:@"sankaku"] || [site isEqualToString:@"konachan"])) {
            if ([postNumbers count] < 1)
                for (NSInteger i = [page newestPostNumber]; i >= 0; i--)
                    [postNumbers addObject:[NSString stringWithFormat:@"%@ - %lu", longSite, i]];
            for (NSInteger i = 0; i < [postNumbers count]; i++) {
                postNumber = [[[[postNumbers objectAtIndex:i] componentsSeparatedByString:@" - "] objectAtIndex:1] integerValue];
                if (!pathContainsPost(to, longSite, postNumber)) {
                    fprintf(stdout, "Downloading post \"%s - %li\"... ", [longSite UTF8String], postNumber);
                    post = [page postWithNumber:postNumber];
                    if ([post postExists]) {
                        NSString* file = [to stringByAppendingPathComponent:[post fileName]];
                        [[post originalImageData] writeToFile:file atomically:YES];
                        clearMarkers(to, longSite, postNumber);
                        fprintf(stdout, "%.2f%% done\n", ((float)i+1)/(float)[postNumbers count]*100);
                    } else {
                        postDoesNotExist(to, longSite, postNumber);
                        fprintf(stdout, "does not exist, %.2f%% done\n", ((float)i+1)/(float)[postNumbers count]*100.0);
                    }
                }
            }
        }
    }
    return 0;
}

BOOL pathContainsPost(NSString* path, NSString* longSite, NSInteger postNumber) {
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.3", longSite, postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.jpg", longSite, postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.png", longSite, postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.gif", longSite, postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.jpeg", longSite, postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld.swf", longSite, postNumber]]])
        return YES;
    return NO;
}

void postDoesNotExist(NSString* path, NSString* longSite, NSInteger postNumber) {
    NSString* temp = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld", longSite, postNumber]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@.1", temp]]) {
        [fm moveItemAtPath:[NSString stringWithFormat:@"%@.1", temp] toPath:[NSString stringWithFormat:@"%@.2", temp] error:nil];
        return;
    }
    if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@.2", temp]]) {
        [fm moveItemAtPath:[NSString stringWithFormat:@"%@.2", temp] toPath:[NSString stringWithFormat:@"%@.3", temp] error:nil];
        return;
    }
    [[NSString string] writeToFile:[NSString stringWithFormat:@"%@.1", temp] atomically:YES encoding:NSUTF8StringEncoding error:nil];
}

void clearMarkers(NSString* path, NSString* longSite, NSInteger postNumber) {
    NSString* temp = [path stringByAppendingPathComponent:[NSString stringWithFormat:@"%@ - %ld", longSite, postNumber]];
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@.1", temp]])
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@.1", temp] error:nil];
    if ([fm fileExistsAtPath:[NSString stringWithFormat:@"%@.2", temp]])
        [fm removeItemAtPath:[NSString stringWithFormat:@"%@.2", temp] error:nil];
}