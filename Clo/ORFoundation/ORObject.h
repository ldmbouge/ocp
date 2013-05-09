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

@interface ORObject : NSObject<ORObject> {
   id      _impl;
   ORUInt  _name;
   BOOL    _ba[4];
}
-(id)init;
-(void)setId:(ORUInt)name;
-(ORUInt)getId;
@end

<<<<<<< HEAD
//@interface ORModelingObjectI : ORObject<ORObject>
//-(id) init;
////-(void) setImpl: (id) impl;
////-(id) impl;
////-(void) makeImpl;
//@end;

//@interface ORDualUseObjectI : ORObject<ORObject>
//-(id) init;
////-(void) setImpl: (id) impl;
////-(id) impl;
////-(void) makeImpl;
//@end;
=======
@interface ORModelingObjectI : ORObject<ORObject>
-(id) init;
@end;

@interface ORDualUseObjectI : ORObject<ORObject>
-(id) init;
@end;
>>>>>>> 0f5c294bd2fc498e2d14935eb9e9dfe2a5286359
