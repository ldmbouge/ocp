/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORModeling/ORModeling.h>
#import <objcp/CPVar.h>
#import <CPScheduler/CPTask.h>

@interface CPTaskVar : ORObject<CPTaskVar>
-(id<CPTaskVar>) initCPTaskVar: (id<CPEngine>) engine horizon: (id<ORIntRange>) horizon duration: (ORInt) duration;
-(void) changeStartEvt;
-(void) changeEndEvt;
@end
