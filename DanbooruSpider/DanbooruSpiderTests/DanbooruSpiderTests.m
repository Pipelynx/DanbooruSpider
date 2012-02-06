//
//  DanbooruSpiderTests.m
//  DanbooruSpiderTests
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import "DanbooruSpiderTests.h"

@implementation DanbooruSpiderTests

- (void)setUp
{
    [super setUp];
    
    _sankaku = [PLSankaku page];
    _konachan = [PLKonachan page];
    _donmai = [PLDonmai page];
}

- (void)tearDown
{
    // Tear-down code here.
    
    [super tearDown];
}

- (void)testSankaku {
    NSLog(@"Newest post number: %ld", [_sankaku newestPostNumber]);
    
    PLSankakuPost* post = [_sankaku postWithNumber:[_sankaku newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
    
    post = [_sankaku postWithNumber:1220031];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
}

- (void)testKonachan {
    NSLog(@"Newest post number: %ld", [_konachan newestPostNumber]);
    
    PLKonachanPost* post = [_konachan postWithNumber:[_konachan newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post getPNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
    
    post = [_konachan postWithNumber:126963];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post getPNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
}

- (void)testDonmai {
    NSLog(@"Newest post number: %ld", [_donmai newestPostNumber]);
    
    PLDonmaiPost* post = [_donmai postWithNumber:[_donmai newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post getPNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
    
    post = [_donmai postWithNumber:1091099];
    NSLog(@"Original image URL: %@", [[post getOriginalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post getPNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post getTags]);
    NSLog(@"Vote average: %@", [post getVoteAverage]);
    NSLog(@"Rating: %@", [post getRating]);
}

@end
