//
//  DanbooruSpiderTests.h
//  DanbooruSpiderTests
//
//  Created by Martin Fellner on 060212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <SenTestingKit/SenTestingKit.h>
#import "/usr/include/sqlite3.h"

#import "PLSankaku.h"
#import "PLKonachan.h"
#import "PLDonmai.h"

@interface DanbooruSpiderTests : SenTestCase {
    PLSankaku* _sankaku;
    PLKonachan* _konachan;
    PLDonmai* _donmai;
}

@end