/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPUKernel.h>
#import <CPUKernel/CPConstraintI.h>

@class CPGroupController;

@interface CPGroup : CPCoreConstraint<CPGroup> {
   CPEngineI*               _engine;
   CPAC3Queue*              _ac3[NBPRIORITIES];
   CPAC5Queue*              _ac5;
   CPGroupController*       _controller;
}
-(id)init:(id<CPEngine>)engine;
-(void)add:(id<CPConstraint>)p;
-(void)scheduleAC3:(id<CPEventNode>)evt;
-(void)scheduleAC5:(id<CPAC5Event>)evt;
-(ORStatus) post;
-(ORStatus)propagate;
-(id<CPConstraint>)controller;
-(id<OREngine>)engine;
@end

@interface CPBergeGroup : CPCoreConstraint<CPGroup> {
   CPEngineI*               _engine;
   CPGroupController*       _controller;
   id<CPConstraint>*        _inGroup;
   id<CPEventNode>*         _scanMap;
   ORInt                    _nbIn;
   ORInt                    _max;
   ORInt                    _low;
   ORInt                    _sz;
   ORInt*                   _map;
}
-(id)init:(id<CPEngine>)engine;
-(void)add:(id<CPConstraint>)p;
-(void)scheduleAC3:(id<CPEventNode>)evt;
-(void)scheduleAC5:(id<CPAC5Event>)evt;
-(ORStatus) post;
-(ORStatus)propagate;
-(id<CPConstraint>)controller;
-(id<OREngine>)engine;
@end

@interface CPGroupController : CPCoreConstraint {
   CPGroup*    _toRun;
}
-(id)initGroupController:(id<CPGroup>)g;
-(ORStatus) post;
-(void) propagate;
@end