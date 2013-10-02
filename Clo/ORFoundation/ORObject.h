/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORData.h>

// pvh: Do I need the implementation to be visible
// ldm: We must, because CPCoreConstraint in CPUKernel is public and inherits from ORObject

@interface ORObject : NSObject<ORObject> {
   ORUInt  _name;
   //ORUInt  _rc;
   BOOL    _ba[4];
}
-(id)init;
-(void)setId:(ORUInt)name;
-(ORUInt)getId;
@end

