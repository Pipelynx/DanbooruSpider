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
#define ImportFile @"tell application \"Aperture\"\ntell library 1\nset images to import \"%@\" as alias into project \"Sankaku\" by moving\nif ((count of images) > 0) then\ntell item 1 of images\nset color label to %@\ndelete (every keyword of item 1 of images)\n%@end tell\nend if\nend tell\nend tell"
#define SetKeywords @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nif ((count of images) > 0) then\ntell item 1 of images\ndelete (every keyword of item 1 of images)\n%@end tell\nend if\nend tell\nend tell"
#define MakeKeyword @"make new keyword with properties {name:\"%@\", parents:\"%@\"}\n"

BOOL apertureContains(NSInteger);
void apertureImport(NSString*, NSString*, NSArray*);
BOOL pathContains(NSFileManager*, NSString*, NSInteger);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        //[[[NSAppleScript alloc] initWithSource:Quit] executeAndReturnError:nil];
        NSFileManager* fm = [NSFileManager defaultManager];
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        NSInteger postNumber = [args integerForKey:@"from"];
        NSInteger to = [args integerForKey:@"to"];
        PLSankaku* page = [PLSankaku page];
        PLSankakuPost* post = [page postWithNumber:postNumber];
        if (to == 0)
            to = [page newestPostNumber];
        while (postNumber <= to) {
            if (!apertureContains(postNumber)) {
                fprintf(stdout, "%ld >> not imported\n", postNumber);
                [post setPostNumber:postNumber andUpdate:YES];
                if (!pathContains(fm, TempPath, postNumber)) {
                    if ([post postExists]) {
                        fprintf(stdout, "%ld >> downloading\n", postNumber);
                        [[post originalImageData] writeToFile:[TempPath stringByAppendingPathComponent:[post fileName]] atomically:YES];
                    } else {
                        fprintf(stdout, "%ld >> does not exist\n\n", postNumber);
                        postNumber++;
                        continue;
                    }
                }
                else {
                    fprintf(stdout, "%ld >> exists\n", postNumber);
                }
                apertureImport([ASTempPath stringByAppendingString:[post fileName]], [post rating], [post tags]);
                fprintf(stdout, "%ld >> imported\n\n", postNumber);
            }
            postNumber++;
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