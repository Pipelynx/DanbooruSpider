//
//  main.m
//  DanbooruSpiderCLI
//
//  Created by Martin Fellner on 070212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

NSManagedObjectModel *managedObjectModel(void);
NSManagedObjectContext *managedObjectContext(void);
BOOL checkSankakuExists(NSInteger, NSManagedObjectContext*);
BOOL checkKonachanExists(NSInteger, NSManagedObjectContext*);
BOOL checkDonmaiExists(NSInteger, NSManagedObjectContext*);

#import "PLSankaku.h"
#import "PLKonachan.h"
#import "PLDonmai.h"

int main (int argc, const char * argv[])
{

        @autoreleasepool {
            NSError *error = nil; 
            // Create the managed object context
            NSManagedObjectContext* context = managedObjectContext();
            NSManagedObject* mo;
            
            PLSankaku* sankaku = [PLSankaku page];
            PLSankakuPost* sPost = [sankaku newestPost];
            PLKonachan* konachan = [PLKonachan page];
            PLKonachanPost* kPost = [konachan newestPost];
            PLDonmai* donmai = [PLDonmai page];
            PLDonmaiPost* dPost = [donmai newestPost];
            
            while ([sPost postNumber] >= 0) {
                if (!checkSankakuExists([sPost postNumber], context)) {
                    mo = [NSEntityDescription insertNewObjectForEntityForName:@"SankakuPost" inManagedObjectContext:context];
                    [mo setValue:[NSString stringWithFormat:@"%ld", [sPost postNumber]] forKey:@"postNumber"];
                    [mo setValue:[[sPost originalImageURL] absoluteString] forKey:@"originalURL"];
                    NSLog(@"%ld :: %@", [sPost postNumber], [[sPost originalImageURL] absoluteString]);
                    error = nil;
                    if (![context save:&error]) {
                        NSLog(@"Error while saving %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
                        exit(1);
                    }
                }
                [sPost previousPost];
            }
        }
    return 0;
}

BOOL checkSankakuExists(NSInteger postNumber, NSManagedObjectContext* context) {
        NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"SankakuPost"];
        [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %@", [NSString stringWithFormat:@"%ld", postNumber]]];
        NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
        if ([fetchedObjects count] > 0)
            return YES;
    return NO;
}
BOOL checkKonachanExists(NSInteger postNumber, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"KonachanPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %@", [NSString stringWithFormat:@"%ld", postNumber]]];
    NSArray* fetchedObjects = [context executeFetchRequest:fetchRequest error:nil];
    if ([fetchedObjects count] > 0)
        return YES;
    return NO;
}
BOOL checkDonmaiExists(NSInteger postNumber, NSManagedObjectContext* context) {
    NSFetchRequest* fetchRequest = [NSFetchRequest fetchRequestWithEntityName:@"DonmaiPost"];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"postNumber == %@", [NSString stringWithFormat:@"%ld", postNumber]]];
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
    path = [path stringByDeletingPathExtension];
    NSURL* modelURL = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"momd"]];
    model = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    
    return model;
}

NSManagedObjectContext *managedObjectContext() {

    static NSManagedObjectContext* context = nil;
    if (context != nil) {
        return context;
    }

    @autoreleasepool {
        context = [[NSManagedObjectContext alloc] init];
        
        NSPersistentStoreCoordinator *coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:managedObjectModel()];
        [context setPersistentStoreCoordinator:coordinator];
        
        NSString* STORE_TYPE = NSSQLiteStoreType;
        
        NSString* path = @"/Users/Pipelynx/Documents/Sankaku/sankaku.sqlite";
        path = [path stringByDeletingPathExtension];
        NSURL* url = [NSURL fileURLWithPath:[path stringByAppendingPathExtension:@"sqlite"]];
        
        NSError* error;
        NSPersistentStore *newStore = [coordinator addPersistentStoreWithType:STORE_TYPE configuration:nil URL:url options:nil error:&error];
        
        if (newStore == nil) {
            NSLog(@"Store Configuration Failure %@", ([error localizedDescription] != nil) ? [error localizedDescription] : @"Unknown Error");
        }
    }
    return context;
}

