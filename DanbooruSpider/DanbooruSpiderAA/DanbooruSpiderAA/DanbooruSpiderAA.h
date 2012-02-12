//
//  DanbooruSpiderAA.h
//  DanbooruSpiderAA
//
//  Created by Martin Fellner on 110212.
//  Copyright (c) 2012 PiKp (gebbwgl). All rights reserved.
//

#import <Automator/AMBundleAction.h>

@interface DanbooruSpiderAA : AMBundleAction

- (id)runWithInput:(id)input fromAction:(AMAction *)anAction error:(NSDictionary **)errorInfo;

@end
