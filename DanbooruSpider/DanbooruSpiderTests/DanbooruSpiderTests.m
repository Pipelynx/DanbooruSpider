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
    NSLog(@"%@", post);
    
    post = [_sankaku postWithNumber:1220031];
    NSLog(@"%@", post);
}

- (void)testKonachan {
    NSLog(@"Newest post number: %ld", [_konachan newestPostNumber]);
    
    PLKonachanPost* post = [_konachan postWithNumber:[_konachan newestPostNumber]];
    NSLog(@"%@", post);
    
    post = [_konachan postWithNumber:126963];
    NSLog(@"%@", post);
}

- (void)testDonmai {
    NSLog(@"Newest post number: %ld", [_donmai newestPostNumber]);
    
    PLDonmaiPost* post = [_donmai postWithNumber:[_donmai newestPostNumber]];
    NSLog(@"%@", post);
    
    post = [_donmai postWithNumber:1091099];
    NSLog(@"%@", post);
}

- (void)testPreviousNext {
    PLSankakuPost* post = [_sankaku postWithNumber:1220031];
    NSLog(@"%@", post);
    
    [post previousPost];
    NSLog(@"%@", post);
    
    [post setPostNumber:1220022 andUpdate:YES];
    NSLog(@"%@", post);
    
    [post nextPost];
    NSLog(@"%@", post);
}

@end
