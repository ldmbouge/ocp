/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>

@protocol ORLocator
-(id)object;
-(id)key;
@end

@interface ORPQueue : NSObject
-(ORPQueue*)init:(BOOL(^)(id,id))cmp;
-(void)buildHeap;
-(id<ORLocator>)addObject:(id)obj forKey:(id)key;
-(id<ORLocator>)insertObject:(id)obj withKey:(id)key;
-(void)update:(id<ORLocator>)loc toKey:(id)key;
-(id)peekAtKey;
-(id)peekAtObject;
-(id)extractBest;
-(ORInt)size;
-(BOOL)empty;
-(NSString*)description;
@end
