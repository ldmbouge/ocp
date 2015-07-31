/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>

#if defined(__x86_64__) && defined(__APPLE__) && TARGET_OS_IPHONE==0
#import <Cocoa/Cocoa.h>
#endif

void mallocWatch();
NSString* mallocReport();
