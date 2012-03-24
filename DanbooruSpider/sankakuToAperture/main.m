//
//  main.m
//  sankakuToAperture
//
//  Created by Martin Fellner on 260212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLSankaku.h"

#define TempPath @"/Volumes/Hyou/Sankaku/"
#define ASTempPath @"Hyou:Sankaku:"
#define Quit @"tell application \"Aperture\" to quit"
#define CheckExists @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nif ((count of images) > 0) then\nreturn \"exists\"\nend if\nend tell\nend tell"
#define ImportFile @"tell application \"Aperture\"\ntell library 1\nset images to import \"%@\" as alias into project \"Import\" by moving\nif ((count of images) > 0) then\ntell item 1 of images\nset color label to %@\ndelete (every keyword of item 1 of images)\n%@end tell\nend if\nend tell\nend tell"
#define SetKeywords @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nif ((count of images) > 0) then\ntell item 1 of images\ndelete (every keyword of item 1 of images)\nset color label to %@\n%@end tell\nend if\nend tell\nend tell"
#define MakeKeyword @"make new keyword with properties {name:\"%@\", parents:\"%@\"}\n"

BOOL apertureContains(NSInteger);
BOOL postIsFlash(NSInteger);
void apertureImport(NSString*, NSString*, NSArray*);
void apertureTagPhoto(NSInteger, NSString*, NSArray*);
NSString* getApertureTagPhoto(NSInteger, NSString*, NSArray*);
BOOL pathContains(NSInteger);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
#pragma mark Initial definitions
        //[[[NSAppleScript alloc] initWithSource:Quit] executeAndReturnError:nil];
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        NSString* mode = [args stringForKey:@"mode"];
        PLSankaku* page = [PLSankaku page];
        PLSankakuPost* post = nil;
        
#pragma mark Parsing number string
        
        NSMutableArray* numbers = [NSMutableArray array];
        NSArray* numbersArg = [[args stringForKey:@"n"] componentsSeparatedByString:@","];
        NSArray* element = nil;
        NSInteger low, high;
        for (NSInteger i = 0; i < [numbersArg count]; i++) {
            element = [[numbersArg objectAtIndex:i] componentsSeparatedByString:@"-"];
            if ([element count] > 1) {
                if ([[element objectAtIndex:0] integerValue] < [[element objectAtIndex:1] integerValue]) {
                    low = [[element objectAtIndex:0] integerValue];
                    high = [[element objectAtIndex:1] integerValue];
                } else {
                    low = [[element objectAtIndex:1] integerValue];
                    high = [[element objectAtIndex:0] integerValue];
                }
                for (NSInteger j = low; j <= high; j++) {
                    [numbers addObject:[NSNumber numberWithInteger:j]];
                }
            }
            else
                [numbers addObject:[NSNumber numberWithInteger:[[element objectAtIndex:0] integerValue]]];
        }
        
#pragma mark Parsing to, from and range parameters
        
        NSInteger from = [args integerForKey:@"from"];
        if ([[args stringForKey:@"from"] isEqualToString:@"maxPost"])
            from = [page newestPostNumber];
        NSInteger to = [args integerForKey:@"to"];
        if ([[args stringForKey:@"to"] isEqualToString:@"maxPost"])
            to = [page newestPostNumber];
        NSInteger range = [args integerForKey:@"range"];
        if (range != 0) {
            if (to == 0)
                to = from + range;
            if (from == 0)
                from = to - range;
        }
        if (to == 0 && [numbers count] == 0)
            to = [page newestPostNumber];
        if (to < from) {
            NSInteger h = to;
            to = from;
            from = h;
        }
        if (to != from)
            for (NSInteger i = from; i <= to; i++)
                [numbers addObject:[NSNumber numberWithInteger:i]];
        
#pragma mark Import mode
        
        NSInteger postNumber = [[numbers objectAtIndex:0] integerValue];
        if ([mode isEqualToString:@"import"]) {
            post = [page postWithNumber:postNumber];
            for (NSInteger i = 0; i < [numbers count]; i++) {
                postNumber = [[numbers objectAtIndex:i] integerValue];
                if (!apertureContains(postNumber)) {
                    if (postIsFlash(postNumber)) {
                        fprintf(stdout, "%ld >> is flash animation\n", postNumber);
                        continue;
                    }
                    fprintf(stdout, "%ld >> not imported\n", postNumber);
                    [post setPostNumber:postNumber andUpdate:YES];
                    if (!pathContains(postNumber)) {
                        if ([post postExists]) {
                            fprintf(stdout, "%ld >> downloading\n", postNumber);
                            [[post originalImageData] writeToFile:[TempPath stringByAppendingPathComponent:[post fileName]] atomically:YES];
                        } else {
                            fprintf(stdout, "%ld >> does not exist\n\n", postNumber);
                            continue;
                        }
                    }
                    else {
                        fprintf(stdout, "%ld >> exists\n", postNumber);
                    }
                    apertureImport([ASTempPath stringByAppendingString:[post fileName]], [post rating], [post tags]);
                    fprintf(stdout, "%ld >> imported\n\n", postNumber);
                }
            }
        }
        
#pragma mark Tag mode
        
        if ([mode isEqualToString:@"tag"]) {
            for (NSInteger i = 0; i < [numbers count]; i++) {
                postNumber = [[numbers objectAtIndex:i] integerValue];
                post = [page postWithNumber:postNumber];
                //NSLog(@"%@", post);
                if (apertureContains(postNumber)) {
                    //NSLog(@"%@", [post tags]);
                    apertureTagPhoto(postNumber, [post rating], [post tags]);
                    fprintf(stdout, "%ld >> tagged\n", postNumber);
                }
            }
        }
        
#pragma mark TagScript mode
        
        if ([mode isEqualToString:@"tagscript"]) {
            NSMutableString* script = [NSMutableString string];
            for (NSInteger i = 0; i < [numbers count]; i++) {
                postNumber = [[numbers objectAtIndex:i] integerValue];
                post = [page postWithNumber:postNumber];
                //NSLog(@"%@", post);
                if (apertureContains(postNumber)) {
                    //NSLog(@"%@", [post tags]);
                    [script appendFormat:@"%@\n", getApertureTagPhoto(postNumber, [post rating], [post tags])];
                }
            }
            fprintf(stdout, "%s", [script UTF8String]);
        }
    }
    return 0;
}

BOOL apertureContains(NSInteger postNumber) {
    if ([[[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:CheckExists, [NSString stringWithFormat:@"%ld", postNumber]]] executeAndReturnError:nil] stringValue])
        return YES;
    else
        return NO;
}

BOOL postIsFlash(NSInteger postNumber) {
    if ([[NSFileManager defaultManager] fileExistsAtPath:[TempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.swf", postNumber]]])
        return YES;
    else
        return NO;
}

void apertureImport(NSString* applescriptPath, NSString* rating, NSArray* tags) {
    NSString* color = nil;
    if ([rating isEqualToString:@"Explicit"])
        color = @"red";
    if ([rating isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([rating isEqualToString:@"Safe"])
        color = @"green";
    NSMutableString* makeKeywords = [NSMutableString string];
    for (int i = 0; i < [tags count]; i++) {
        [makeKeywords appendFormat:MakeKeyword, [[tags objectAtIndex:i] name], [[tags objectAtIndex:i] category]];
    }
    [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:ImportFile, applescriptPath, color, makeKeywords]] executeAndReturnError:nil];
}

void apertureTagPhoto(NSInteger postNumber, NSString* rating, NSArray* tags) {
    NSString* color = nil;
    if ([rating isEqualToString:@"Explicit"])
        color = @"red";
    if ([rating isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([rating isEqualToString:@"Safe"])
        color = @"green";
    NSMutableString* makeKeywords = [NSMutableString string];
    for (int i = 0; i < [tags count]; i++) {
        [makeKeywords appendFormat:MakeKeyword, [[tags objectAtIndex:i] name], [[tags objectAtIndex:i] category]];
    }
    [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:SetKeywords, [NSString stringWithFormat:@"%ld", postNumber], color, makeKeywords]] executeAndReturnError:nil];
}

NSString* getApertureTagPhoto(NSInteger postNumber, NSString* rating, NSArray* tags) {
    NSString* color = nil;
    if ([rating isEqualToString:@"Explicit"])
        color = @"red";
    if ([rating isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([rating isEqualToString:@"Safe"])
        color = @"green";
    NSMutableString* makeKeywords = [NSMutableString string];
    for (int i = 0; i < [tags count]; i++) {
        [makeKeywords appendFormat:MakeKeyword, [[tags objectAtIndex:i] name], [[tags objectAtIndex:i] category]];
    }
    return [NSString stringWithFormat:SetKeywords, [NSString stringWithFormat:@"%ld", postNumber], color, makeKeywords];
}

BOOL pathContains(NSInteger postNumber) {
    NSFileManager* fm = [NSFileManager defaultManager];
    if ([fm fileExistsAtPath:[TempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.jpg", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[TempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.png", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[TempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.gif", postNumber]]])
        return YES;
    if ([fm fileExistsAtPath:[TempPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%ld.swf", postNumber]]])
        return YES;
    NSArray* files = [fm contentsOfDirectoryAtPath:TempPath error:nil];
    for (NSInteger i = 0; i < [files count]; i++) {
        if ([[files objectAtIndex:i] hasPrefix:[NSString stringWithFormat:@"%ld.", postNumber]])
            return YES;
    }
    return NO;
}