/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraintI.h>

@class CPVarInfo;

// PVH: Need another name for this baby

@interface CPStatisticsMonitor : CPCoreConstraint {
   CPVarInfo**          _varInfo;
   ORLong                  _nbVI;
   id<CPEngine>          _engine;
   CPVarInfo**        _curActive;
   ORUInt              _nbActive;
   id<ORVarArray>        _monVar;
}
-(id)initCPMonitor:(id<CPEngine>)engine vars:(id<ORVarArray>)allVars;
-(ORStatus) post;
-(NSString*) description;
-(double) reduction;
-(double) reductionFromRootForVar:(id)x extraLosses:(ORInt)ks;
-(void)rootRefresh;
-(void)scanActive:(void(^)(CPVarInfo*))block;
@end

@interface CPVarInfo : NSObject {
   @package
   id       _theVar;
   id<ORTrail> _trail;
   TRDouble _oldDSize;
   FXInt    _active;
   @package
   double   _initial;
   double   _final;
   double   _root;
}
-(CPVarInfo*)initCPVarInfo:(id)v trail:(id<ORTrail>)trail;
-(void)makeActive;
-(ORInt)getVarID;
-(id<ORVar>)getVar;
@end
