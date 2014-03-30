/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORData.h>

@interface ORObject : NSObject<ORObject> {
@public
   ORUInt  _name;
@package
   ORUInt  _rc;
   BOOL    _ba[4];
}
-(id)init;
-(void)setId:(ORUInt)name;
-(ORUInt)getId;
@end

static inline ORUInt getId(ORObject* ptr) { return ptr->_name;}