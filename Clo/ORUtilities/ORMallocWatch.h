//
//  ORMallocWatch.h
//  Clo
//
//  Created by Laurent Michel on 1/3/13.
//  Copyright (c) 2013 CSE. All rights reserved.
//

#if defined(__unix__)
#import <Cocoa/Cocoa.h>
#endif

void mallocWatch();
NSString* mallocReport();
