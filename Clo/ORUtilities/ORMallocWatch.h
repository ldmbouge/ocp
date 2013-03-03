//
//  ORMallocWatch.h
//  Clo
//
//  Created by Laurent Michel on 1/3/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#import <Foundation/Foundation.h>

#if defined(__x86_64__) || defined(__MAC_OS_X_VERSION_MIN_REQUIRED)
#import <Cocoa/Cocoa.h>
#endif

void mallocWatch();
NSString* mallocReport();
