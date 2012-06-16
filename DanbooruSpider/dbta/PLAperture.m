//
//  PLAperture.m
//  DanbooruSpider
//
//  Created by Martin Fellner on 310312.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "PLAperture.h"
#define Wrapper @"tell application \"Aperture\"\ntell library 1\n%@end tell\nend tell"
#define GetImageVersionNames @"tell application \"Aperture\"\ntell library 1\nreturn the name of every image version in container \"%@\"\nend tell\nend tell"
#define GetImageVersions @"tell application \"Aperture\"\ntell library 1\nset imageVersions to my bubbleSort(every image version in container \"%@\")\n%@end tell\nend tell\non bubbleSort(theList)\nscript bs\nproperty alist : theList\nend script\nset theCount to length of bs's alist\nif theCount < 2 then return bs's alist\nrepeat with indexA from theCount to 1 by -1\nrepeat with indexB from 1 to indexA - 1\nif name of item indexB of bs's alist > name of item (indexB + 1) of bs's alist then\nset temp to item indexB of bs's alist\nset item indexB of bs's alist to item (indexB + 1) of bs's alist\nset item (indexB + 1) of bs's alist to temp\nend if\nend repeat\nend repeat\nreturn bs's alist\nend bubbleSort"
#define CheckExists @"tell application \"Aperture\"\ntell library 1\nset images to (every image version where name is \"%@\")\nrepeat with image in images\nif \"%@\" is in name of parent of image then\nreturn \"exists\"\nend if\nend repeat\nend tell\nend tell"
#define POSIXFile @"POSIX file \"%@\""
#define ImportFiles @"tell application \"Aperture\"\ntell library 1\nset imageVersions to import { %@ } into project \"%@\" by moving\n%@end tell\nend tell\non bubbleSort(theList)\nscript bs\nproperty alist : theList\nend script\nset theCount to length of bs's alist\nif theCount < 2 then return bs's alist\nrepeat with indexA from theCount to 1 by -1\nrepeat with indexB from 1 to indexA - 1\nif name of item indexB of bs's alist > name of item (indexB + 1) of bs's alist then\nset temp to item indexB of bs's alist\nset item indexB of bs's alist to item (indexB + 1) of bs's alist\nset item (indexB + 1) of bs's alist to temp\nend if\nend repeat\nend repeat\nreturn bs's alist\nend bubbleSort"
#define TagImage @"delete (every keyword of item %i of imageVersions)\n%@"
#define TagImage2 @"set imageVersions to every image version where name = \"%@\"\nrepeat with image in imageVersions\ntell image\ndelete every keyword\n%@end tell\nend repeat\n"
#define ImportTagImage @"tell item %i of imageVersions\n%@"
#define SetTag @"{name:\"%@\",parents:\"%@\"}"
#define SetColor @"set color label to %@\n"
#define SetTags @"set tag%ld to {%@,{%@}}\n"
#define ApplyTags @"set imageVersions to every image version of container \"Tag\"\nrepeat with image in imageVersions\nset imageName to the name of image\n%@end repeat\n"
#define ApplyTag @"if (imageName = \"%@\") then\ntell image\nrepeat with tag in item 2 of tag%ld\nmake new keyword with properties tag\nend repeat\nset color label to item 1 of tag%ld\nend tell\nend if\n"

@implementation PLAperture

+ (NSArray*)imageVersionsWithContainerName:(NSString*)containerName {
    NSAppleEventDescriptor* event = [[[NSAppleScript alloc] initWithSource:[NSString stringWithFormat:GetImageVersionNames, containerName]] executeAndReturnError:nil];
    NSMutableArray* result = [NSMutableArray array];
    NSInteger i = 1;
    NSString* string;
    while ((string = [[event descriptorAtIndex:i] stringValue])) {
        [result addObject:string];
        i++;
    }
    return [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

+ (NSString*)scriptForApplyingTagsToPostNumbers:(NSArray*)postNumbers {
    NSInteger postNumber;
    NSMutableString* applyTags = [NSMutableString string];
    for (NSInteger i = 0; i < [postNumbers count]; i++) {
        postNumber = [[[[postNumbers objectAtIndex:i] componentsSeparatedByString:@" - "] objectAtIndex:1] integerValue];
        [applyTags appendFormat:ApplyTag, [postNumbers objectAtIndex:i], postNumber, postNumber];
    }
    return [NSString stringWithFormat:ApplyTags, applyTags];
}

+ (NSString*)scriptForSettingTagsForPost:(PLPost*)post {
    NSString* color = nil;
    if ([[post rating] isEqualToString:@"Explicit"])
        color = @"red";
    if ([[post rating] isEqualToString:@"Questionable"])
        color = @"yellow";
    if ([[post rating] isEqualToString:@"Safe"])
        color = @"green";
    if (![post postExists])
        color = @"gray";
    NSMutableString* tags = [NSMutableString string];
    for (NSInteger i = 0; i < [[post tags] count]; i++) {
        [tags appendFormat:SetTag, [[[[[post tags] objectAtIndex:i] name] stringByReplacingOccurrencesOfString:@"\\" withString:@"\\\\"] stringByReplacingOccurrencesOfString:@"\"" withString:@"\\\""], [[[post tags] objectAtIndex:i] category]];
        if (i < ([[post tags] count] - 1))
            [tags appendString:@","];
    }
    return [NSString stringWithFormat:SetTags, [post postNumber], color, tags];
}

+ (NSString*)scriptForOperations:(NSString*)operations {
    return [NSString stringWithFormat:Wrapper, operations];
}

+ (NSString*)scriptForGettingImageVersionsWithContainerName:(NSString*)containerName andOperations:(NSString*)operations {
    return [NSString stringWithFormat:GetImageVersions, containerName, operations];
}

+ (NSString*)scriptForImportingImagesWithFiles:(NSArray*)files andOperations:(NSString*)operations intoProject:(NSString*)project {
    if ([files count] > 0) {
        NSMutableString* filesString = [NSMutableString stringWithFormat:POSIXFile, [files objectAtIndex:0]];
        for (NSInteger i = 1; i < [files count]; i++)
            [filesString appendFormat:@" , %@", [NSString stringWithFormat:POSIXFile, [files objectAtIndex:i]]];
        return [NSString stringWithFormat:ImportFiles, filesString, project, operations];
    }
    else
        return nil;
}

@end
