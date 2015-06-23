/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>

@interface NSCont : NSObject
+(id)new;
-(void)saveStack:(size_t)len startAt:(void*)s;
-(void)call; 
-(ORInt)nbCalls;
-(void)dealloc;
-(void)letgo;
-(NSCont*) grab;
+(NSCont*) takeContinuation;
+(void)shutdown;
@property (readwrite,assign) ORInt field;
@property (readwrite,retain) id  fieldId;
@end 

void letgo(NSCont*);

void initContinuationLibrary(int *base);
char* getContBase();
