//
//  main.m
//  sankakuToAperture
//
//  Created by Martin Fellner on 260212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PLSankaku.h"
#import "PLKonachan.h"

#define TempPath [@"~/Pictures/" stringByExpandingTildeInPath]
#define Quit @"tell application \"Aperture\" to quit"
#define GetPhotos @"tell application \"Aperture\"\ntell library 1\nreturn the name of every image version in container \"%@\"\nend tell\nend tell"
#define CheckExists @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nrepeat with image in images\nif \"%@\" is in name of parent of image then\nreturn \"exists\"\nend if\nend repeat\nend tell\nend tell"
#define ImportFile @"tell application \"Aperture\"\ntell library 1\nset images to import POSIX file \"%@\" into project \"Import\" by moving\nif ((count of images) > 0) then\ntell item 1 of images\nset color label to %@\ndelete (every keyword of item 1 of images)\n%@end tell\nend if\nend tell\nend tell"
#define SetKeywords @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nif ((count of images) > 0) then\ntell item 1 of images\ndelete (every keyword of item 1 of images)\nset color label to %@\n%@end tell\nend if\nend tell\nend tell"
#define MakeKeyword @"make new keyword with properties {name:\"%@\", parents:\"%@\"}\n"

BOOL apertureContains(NSString*, NSString*);
BOOL postIsFlash(NSInteger);
void apertureImport(NSString*, PLPost*);
void apertureTagPhoto(PLPost*);
NSArray* apertureGetPhotos(NSString*);
BOOL pathContains(NSInteger);

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSUserDefaults* params = [NSUserDefaults standardUserDefaults];
        NSString* site = [params stringForKey:@"site"];
        NSString* longSite = nil;
        if ([site isEqualToString:@"konachan"])
            longSite = @"Konachan";
        if ([site isEqualToString:@"sankaku"])
            longSite = @"Sankaku Channel";
        NSString* mode = [params stringForKey:@"mode"];
        NSString* album = [params stringForKey:@"album"];
        NSString* project = [params stringForKey:@"project"];
        
        NSMutableOrderedSet* postNumbers = [NSMutableOrderedSet orderedSet];
        if (album) {
            fprintf(stdout, "Getting photos for album %s... ", [album UTF8String]);
            [postNumbers addObjectsFromArray:apertureGetPhotos(album)];
            fprintf(stdout, "got %lu photos\n", [postNumbers count]);
        }
        if ([[params stringForKey:@"range"] rangeOfString:@"-"].location > 0)
            for (NSInteger i = [[[[params stringForKey:@"range"] componentsSeparatedByString:@"-"] objectAtIndex:0] integerValue]; i <= [[[[params stringForKey:@"range"] componentsSeparatedByString:@"-"] objectAtIndex:1] integerValue]; i++) {
                [postNumbers addObject:[NSString stringWithFormat:@"%@ - %li", longSite, i]];
            }
        
        NSLog(@"%@", postNumbers);
        #pragma mark Tag mode
        if ([mode isEqualToString:@"tag"]) {
            
            PLKonachan* page;
            fprintf(stdout, "Getting Konachan... ");
            page = [PLKonachan page];
            PLKonachanPost* post = [page newestPost];
            if ([postNumbers count] < 1) {
                for (NSInteger i = [page newestPostNumber]; i >= 0; i--) {
                    [postNumbers addObject:[NSString stringWithFormat:@"%li", i]];
                }
            }
            fprintf(stdout, "done\n");
            
            for (NSInteger i = 0; i < [postNumbers count]; i++) {
                fprintf(stdout, "Tagging photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                [post setPostNumber:[[[[postNumbers objectAtIndex:i] componentsSeparatedByString:@" - "] objectAtIndex:1] integerValue] andUpdate:YES];
                apertureTagPhoto(post);
                fprintf(stdout, "done\n");
            }
        }
        
        if ([site isEqualToString:@"konachan"]) {
            PLKonachan* page;
            fprintf(stdout, "Getting Konachan... ");
            page = [PLKonachan page];
            PLKonachanPost* post = [page newestPost];
            if ([postNumbers count] < 1) {
                for (NSInteger i = [page newestPostNumber]; i >= 0; i--) {
                    [postNumbers addObject:[NSString stringWithFormat:@"%li", i]];
                }
            }
            fprintf(stdout, "done\n");
            
#pragma mark Tag mode
            if ([mode isEqualToString:@"tag"]) {
                if (album) {
                    fprintf(stdout, "Getting photos for album %s... ", [album UTF8String]);
                    postNumbers = [NSMutableArray arrayWithArray:apertureGetPhotos(album)];
                    fprintf(stdout, "got %lu photos\n", [postNumbers count]);
                }
                for (NSInteger i = 0; i < [postNumbers count]; i++) {
                    fprintf(stdout, "Tagging photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    [post setPostNumber:[[postNumbers objectAtIndex:i] integerValue] andUpdate:YES];
                    apertureTagPhoto(post);
                    fprintf(stdout, "done\n");
                }
            }
            
#pragma mark Import mode
            if ([[params stringForKey:@"mode"] isEqualToString:@"import"]) {
                if (!project)
                    project = @"Import";
                for (NSInteger i = 0; i < [postNumbers count]; i++) {
                    if (apertureContains([postNumbers objectAtIndex:i], site)) {
                        fprintf(stdout, "Library already contains photo %s", [[postNumbers objectAtIndex:i] UTF8String]);
                        continue;
                    }
                    fprintf(stdout, "Dowloading photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    [post setPostNumber:[[postNumbers objectAtIndex:i] integerValue] andUpdate:YES];
                    NSString* path = [TempPath stringByAppendingPathComponent:[post fileName]];
                    [[post originalImageData] writeToFile:path atomically:YES];
                    fprintf(stdout, "done\n");
                    fprintf(stdout, "Importing photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    apertureImport(path, post);
                    fprintf(stdout, "done\n");
                }
            }
        }
        
        if ([site isEqualToString:@"sankaku"]) {
            PLSankaku* page;
            fprintf(stdout, "Getting Sankaku Channel... ");
            page = [PLSankaku page];
            PLSankakuPost* post = [page newestPost];
            if ([postNumbers count] < 1) {
                for (NSInteger i = [page newestPostNumber]; i >= 0; i--) {
                    [postNumbers addObject:[NSString stringWithFormat:@"%li", i]];
                }
            }
            fprintf(stdout, "done\n");
            
#pragma mark Tag mode
            if ([[params stringForKey:@"mode"] isEqualToString:@"tag"]) {
                if (album) {
                    fprintf(stdout, "Getting photos for album %s... ", [album UTF8String]);
                    postNumbers = [NSMutableArray arrayWithArray:apertureGetPhotos(album)];
                    fprintf(stdout, "got %lu photos\n", [postNumbers count]);
                }
                for (NSInteger i = 0; i < [postNumbers count]; i++) {
                    fprintf(stdout, "Tagging photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    [post setPostNumber:[[postNumbers objectAtIndex:i] integerValue] andUpdate:YES];
                    apertureTagPhoto(post);
                    fprintf(stdout, "done\n");
                }
            }
            
#pragma mark Import mode
            if ([[params stringForKey:@"mode"] isEqualToString:@"import"]) {
                if (!project)
                    project = @"Import";
                for (NSInteger i = 0; i < [postNumbers count]; i++) {
                    if (apertureContains([postNumbers objectAtIndex:i], site)) {
                        fprintf(stdout, "Library already contains photo %s", [[postNumbers objectAtIndex:i] UTF8String]);
                        continue;
                    }
                    fprintf(stdout, "Dowloading photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    [post setPostNumber:[[postNumbers objectAtIndex:i] integerValue] andUpdate:YES];
                    NSString* path = [TempPath stringByAppendingPathComponent:[post fileName]];
                    [[post originalImageData] writeToFile:path atomically:YES];
                    fprintf(stdout, "done\n");
                    fprintf(stdout, "Importing photo %s... ", [[postNumbers objectAtIndex:i] UTF8String]);
                    apertureImport(path, post);
                    fprintf(stdout, "done\n");
                }
            }
        }
    }
    return 0;
}

BOOL apertureContains(NSString* postNumber, NSString* site) {
    NSString* class = nil;
    if ([site isEqualToString:@"sankaku"])
        class = @"Sankaku Channel";
    if ([site isEqualToString:@"konachan"])
        class = @"Konachan";
    if ([[[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:CheckExists, [NSString stringWithFormat:@"%@ - %@", class, postNumber], site]] executeAndReturnError:nil] stringValue])
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

void apertureImport(NSString* path, PLPost* post) {
    NSString* color = nil;
    if ([[post rating] isEqualToString:@"Explicit"])
        color = @"red";
    if ([[post rating] isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([[post rating] isEqualToString:@"Safe"])
        color = @"green";
    if (![post postExists])
        color = @"gray";
    NSMutableString* makeKeywords = [NSMutableString string];
    for (int i = 0; i < [[post tags] count]; i++) {
        [makeKeywords appendFormat:MakeKeyword, [[[[post tags] objectAtIndex:i] name] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"], [[[post tags] objectAtIndex:i] category]];
    }
    [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:ImportFile, path, color, makeKeywords]] executeAndReturnError:nil];
}

void apertureTagPhoto(PLPost* post) {
    //NSLog(@"%@", post);
    NSString* class = nil;
    if ([post isKindOfClass:[PLSankakuPost class]])
        class = @"Sankaku Channel";
    if ([post isKindOfClass:[PLKonachanPost class]])
        class = @"Konachan";
    NSString* color = nil;
    if ([[post rating] isEqualToString:@"Explicit"])
        color = @"red";
    if ([[post rating] isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([[post rating] isEqualToString:@"Safe"])
        color = @"green";
    if (![post postExists])
        color = @"gray";
    NSMutableString* makeKeywords = [NSMutableString string];
    for (int i = 0; i < [[post tags] count]; i++) {
        [makeKeywords appendFormat:MakeKeyword, [[[[post tags] objectAtIndex:i] name] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"], [[[post tags] objectAtIndex:i] category]];
    }
    //NSLog(@"%@", [NSString stringWithFormat:SetKeywords, [NSString stringWithFormat:@"%@ - %ld", class, [post postNumber]], color, makeKeywords]);
    [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:SetKeywords, [NSString stringWithFormat:@"%@ - %ld", class, [post postNumber]], color, makeKeywords]] executeAndReturnError:nil];
}

NSArray* apertureGetPhotos(NSString* container) {
    NSAppleEventDescriptor* event = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:GetPhotos, container]] executeAndReturnError:nil];
    NSMutableArray* result = [NSMutableArray array];
    NSInteger i = 1;
    NSString* string;
    while ((string = [[event descriptorAtIndex:i] stringValue])) {
        [result addObject:string];
        i++;
    }
    return [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
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