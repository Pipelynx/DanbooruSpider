//
//  main.m
//  DanbooruSpiderCLI
//
//  Created by Martin Fellner on 070212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

NSManagedObjectModel *managedObjectModel();
NSManagedObjectContext *managedObjectContext(NSString*);
BOOL checkSankakuExists(NSInteger, NSManagedObjectContext*);
NSArray* getSankakuRange(NSInteger, NSInteger, NSManagedObjectContext*);
NSManagedObject* getSankaku(NSInteger, NSManagedObjectContext*);
NSInteger getSankakuRetry(NSInteger, NSManagedObjectContext*);
BOOL checkKonachanExists(NSInteger, NSManagedObjectContext*);
BOOL checkDonmaiExists(NSInteger, NSManagedObjectContext*);

#import "PLSankaku.h"
#import "PLKonachan.h"
#import "PLDonmai.h"

int main (int argc, const char * argv[])
{
    @autoreleasepool {
        NSUserDefaults* args = [NSUserDefaults standardUserDefaults];
        BOOL download = [args boolForKey:@"dl"];
        NSString* database = [args stringForKey:@"db"];
        NSString* service = [args stringForKey:@"service"];
        NSInteger from = [args integerForKey:@"from"];
        NSInteger to = [args integerForKey:@"to"];
        
        NSError *error = nil;
        NSManagedObjectContext* context = managedObjectContext(database);
        NSManagedObject* mo;
        NSArray* mos;
        
        if ([service isCaseInsensitiveLike:@"sankaku"]) {
            PLSankaku* sankaku = [PLSankaku page];
            PLSankakuPost* sPost = [sankaku postWithNumber:from];
            if (download) {
                NSFileManager* fm = [NSFileManager defaultManager];
                mos = getSankakuRange(from, to, context);
                NSString* path;
                for (NSInteger i = 0; i < [mos count]; i++) {
                    mo = [mos objectAtIndex:i];
                    path = [[database stringByDeletingLastPathComponent] stringByAppendingPathComponent:[NSString stringWithFormat:@"%@.%@", [mo valueForKey:@"postNumber"], [[mo valueForKey:@"originalURL"] pathExtension]]];
                    if (![fm fileExistsAtPath:path]) {
                        [sPost setPostNumber:[[mo valueForKey:@"postNumber"] integerValue] andUpdate:YES];
                        [[sPost originalImageData] writeToFile:path atomically:YES];
                        NSLog(@"%@", path);
                    }
                }
            }
            else {
                if (to == 0)
                    to = [sankaku newestPostNumber];
                while ([sPost postNumber] <= to) {
                    if (![sPost postExists]) {
                        if (checkSankakuExists([sPost postNumber], context)) {
                            mo = getSankaku([sPost postNumber], context);
                            [mo setValue:[NSString stringWithFormat:@"%ld", [[mo valueForKey:@"retry"] integerValue] + 1] forKey:@"retry"];
                        }
                        else {
                            mo = [NSEntityDescription insertNewObjectForEntityForName:@"SankakuPost" inManagedObjectContext:context];
                            [mo setValue:[NSString stringWithFormat:@"%ld", [sPost postNumber]] forKey:@"postNumber"];
                        }
                        NSLog(@"%@", sPost);
                        error = nil;
                        if (![context save:&error]) {
                            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
                            exit(1);
                        }
                    }
                    if (!checkSankakuExists([sPost postNumber], context)) {
                        mo = [NSEntityDescription insertNewObjectForEntityForName:@"SankakuPost" inManagedObjectContext:context];
                        [mo setValue:[NSString stringWithFormat:@"%ld", [sPost postNumber]] forKey:@"postNumber"];
                        [mo setValue:[[sPost originalImageURL] absoluteString] forKey:@"originalURL"];
                        NSLog(@"%@", sPost);
                        error = nil;
                        if (![context save:&error]) {
                            NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
                            exit(1);
                        }
                    }
                    NSInteger x = [sPost postNumber] + 1;
                    while (getSankakuRetry(x, context)) {
                        x++;
                    }
                    [sPost setPostNumber:x andUpdate:YES];
                }
            }
        }
        if ([service isCaseInsensitiveLike:@"konachan"]) {
            PLKonachan* konachan = [PLKonachan page];
            PLKonachanPost* kPost = [konachan newestPost];
        }
        if ([service isCaseInsensitiveLike:@"donmai"]) {
            PLDonmai* donmai = [PLDonmai page];
            PLDonmaiPost* dPost = [donmai newestPost];
        }
    }
    return 0;
}

BOOL checkSankakuExists(NSInteger postNumber, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SankakuPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %ls", postNumber]];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    if ([fetchedObjects count] > 0)
        return YES;
    return NO;
}
NSArray* getSankakuRange(NSInteger from, NSInteger to, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SankakuPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber >= %ld AND postNumber <= %ld", from, to]];
    return [context executeFetchRequest:fetchRequest error:nil];
}
NSManagedObject* getSankaku(NSInteger postNumber, NSManagedObjectContext* context) {
    return [getSankakuRange(postNumber, postNumber, context) objectAtIndex:0];
}
NSInteger getSankakuRetry(NSInteger postNumber, NSManagedObjectContext* context) {
    if (checkSankakuExists(postNumber, context)) {
        return [[getSankaku(postNumber, context) valueForKey:@"retry"] integerValue];
    } else {
        return 0;
    }
}
BOOL checkKonachanExists(NSInteger postNumber, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KonachanPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %ls", postNumber]];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    if ([fetchedObjects count] > 0)
        return YES;
    return NO;
}
BOOL checkDonmaiExists(NSInteger postNumber, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DonmaiPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %ls", postNumber]];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    if ([fetchedObjects count] > 0)
        return YES;
    return NO;
}

NSManagedObjectModel *managedObjectModel() {
    
    static NSManagedObjectModel* model = nil;
    
    if (model != nil) {
        return model;
    }
    
    NSString* path = [[[NSProcessInfo processInfo] arguments] objectAtIndex:0];
    NSURL* modelURL = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

NSManagedObjectContext *managedObjectContext(NSString* path) {
    
    static NSManagedObjectContext* context = nil;
    if (context != nil) {
        return context;
    }
    
    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString* STORE_TYPE = NSSQLiteStoreType;
        
        NSURL* url = [NSURL fileURLWithPath:[[path stringByDeletingPathExtension] stringByAppendingPathExtension:@"sqlite"]];
        
        NSError* error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

