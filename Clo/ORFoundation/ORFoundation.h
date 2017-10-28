/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORObject.h>
#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORAVLTree.h>
#import <ORFoundation/ORSet.h>
#import <ORFoundation/ORSetI.h>
#import <ORFoundation/ORFunc.h>
#import <ORFoundation/OREngine.h>
#import <ORFoundation/ORTrail.h>
#import <ORFoundation/ORCommand.h>
#import <ORFoundation/ORTracer.h>
#import <ORFoundation/ORArray.h>
#import <ORFoundation/ORData.h>
#import <ORFoundation/ORConstraint.h>
#import <ORFoundation/ORExpr.h>
#import <ORFoundation/ORSolver.h>
#import <ORFoundation/ORVar.h>
#import <ORFoundation/ORVisit.h>
#import <ORFoundation/ORParameter.h>
#import <ORFoundation/ORAnnotation.h>
#import <ORFoundation/ORSelector.h>
#import <ORFoundation/ORDataI.h>
#import <ORFoundation/ORExprI.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORTrailI.h>

#import <ORFoundation/ORControl.h>
#import <ORFoundation/ORLimit.h>
#import <ORFoundation/ORParallel.h>
#import <ORFoundation/ORController.h>
#import <ORFoundation/ORExplorer.h>
#import <ORFoundation/ORExplorerI.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORFoundation/ORSemFDSController.h>
#import <ORFoundation/ORSemBFSController.h>
#import <ORFoundation/ORBackjumpingDFSController.h>


#if defined(__APPLE__)
#import "TargetConditionals.h"
#endif

ORStatus tryfail(ORStatus(^block)(void),ORStatus(^handle)(void));
#if __cplusplus
extern "C"
#endif
void failNow(void);

#if TARGET_OS_IPHONE

#define TRYFAIL { \
jmp_buf buf; \
NSValue* tv = [NSThread.currentThread.threadDictionary objectForKey:@(2)]; \
jmp_buf* old = tv.pointerValue; \
int st = _setjmp(buf); \
if (st==0) { \
   [NSThread.currentThread.threadDictionary setObject:[NSValue valueWithPointer:&buf] forKey:@(2)]; 

#define ONFAIL(rv) return (rv); \
} else { \
   [NSThread.currentThread.threadDictionary setObject:[NSValue valueWithPointer:old] forKey:@(2)];
#define ENDFAIL(rv) return (rv);}}

#else
extern __thread jmp_buf* ptr;

#define TRYFAIL  { \
jmp_buf buf; \
jmp_buf* old = ptr; \
int st = _setjmp(buf); \
if (st==0) { \
ptr = &buf;

#define ONFAIL(rv)  ptr = old;return (rv); \
} else { \
ptr = old;

#define ENDFAIL(rv) return (rv);}}


#endif

