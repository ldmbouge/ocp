/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>

@class ORVisitor;

@protocol ORObject <NSObject>
-(ORUInt) getId;
-(void)setId:(ORUInt)name;
-(void) visit: (ORVisitor*) visitor;
@end;


@interface ORObject : NSObject<ORObject> {
@public
   ORUInt  _name;
@package
   ORUInt  _rc;
   BOOL    _ba[4];
}
-(id) init;
-(void) setId:(ORUInt)name;
-(ORUInt) getId;
-(id) takeSnapshot: (ORInt) id;
@end

static inline ORUInt getId(const ORObject* ptr) { return ptr->_name;}
