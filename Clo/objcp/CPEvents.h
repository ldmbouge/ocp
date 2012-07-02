/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>

@protocol CPEvent <NSObject>
-(void) whenever:(SEL)selector notify:(id)obj;
-(void) whenever:(SEL)selector notify:(id)obj inScope:(void(^)())closure;
-(void) when:(SEL)selector notify:(id)obj;
@end

@interface CPEventDispatch : NSObject<CPEvent> {
@private
   NSMutableDictionary* _table;
}
-(id)initCPEventCenter:(SEL)s0,...;
-(void)dealloc;
-(void) whenever:(SEL)selector notify:(id)obj;
-(void) whenever:(SEL)selector notify:(id)obj inScope:(void(^)())closure;
-(void) when:(SEL)selector notify:(id)obj;
+(void) dispatchDelayedInvocations;
@end

