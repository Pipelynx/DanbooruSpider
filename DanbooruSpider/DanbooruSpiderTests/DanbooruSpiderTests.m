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
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
    
    post = [_sankaku postWithNumber:1220031];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
}

- (void)testKonachan {
    NSLog(@"Newest post number: %ld", [_konachan newestPostNumber]);
    
    PLKonachanPost* post = [_konachan postWithNumber:[_konachan newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post PNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
    
    post = [_konachan postWithNumber:126963];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post PNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
}

- (void)testDonmai {
    NSLog(@"Newest post number: %ld", [_donmai newestPostNumber]);
    
    PLDonmaiPost* post = [_donmai postWithNumber:[_donmai newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post PNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
    
    post = [_donmai postWithNumber:1091099];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"PNG image URL: %@", [[post PNGImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
}

- (void)testPreviousNext {
    NSLog(@"Newest post number: %ld", [_sankaku newestPostNumber]);
    
    PLSankakuPost* post = [_sankaku postWithNumber:[_sankaku newestPostNumber]];
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
    
    [post previousPost];
    
    NSLog(@"Original image URL: %@", [[post originalImageURL] absoluteString]);
    NSLog(@"Tags: %@", [post tags]);
    NSLog(@"Vote average: %@", [post voteAverage]);
    NSLog(@"Rating: %@", [post rating]);
}

@end
