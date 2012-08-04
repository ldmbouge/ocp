/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <objcp/CPConstraintI.h>
#import <objcp/CPArray.h>

@class CPVarInfo;

// PVH: Need another name for this baby

@interface CPMonitor : CPCoreConstraint {
   CPVarInfo**          _varInfo;
   CPLong                  _nbVI;
   id<CP>                    _cp;
   CPVarInfo**        _curActive;
   CPUInt              _nbActive;
   id<CPVarArray>        _monVar;
}
-(id)initCPMonitor:(id<CP>)cp vars:(id<CPVarArray>)allVars;
-(ORStatus) post;
-(NSString*)description;
-(double)reduction;
-(double)reductionFromRoot;
-(void)scanActive:(void(^)(CPVarInfo*))block;
@end

@interface CPVarInfo : NSObject {
   id       _theVar;
   ORTrail* _trail;
   TRDouble _oldDSize;
   FXInt    _active;
   @package
   double   _initial;
   double   _final;
   double   _root;
}
-(CPVarInfo*)initCPVarInfo:(id)v trail:(ORTrail*)trail;
-(void)makeActive;
@end
