/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPMonitor.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"

@implementation CPVarInfo
-(CPVarInfo*)initCPVarInfo:(id)v trail:(CPTrail*)trail
{
   self = [super init];
   _theVar = v;
   _trail  = trail;
   _initial = _final = _root = [_theVar domsize];
   _oldDSize = makeTRDouble(trail,_initial);
   _active   = makeFXInt(trail);
   return self;
}
-(NSString*)description
{
   NSMutableString* rv = [NSString stringWithFormat:@"<%d,O/N:%lf,A:%d,I:%lf,F:%lf,R:%lf>",
                          [_theVar getId],_oldDSize._val,getFXInt(&_active,_trail),_initial,_final,_root];
   return rv;
}
-(void)dealloc
{
   [super dealloc];
}
-(void)makeActive
{
   incrFXInt(&_active, _trail);
}
inline static void makeVarActive(CPVarInfo* vi)
{
   incrFXInt(&vi->_active, vi->_trail);   
}
BOOL refresh(CPVarInfo* vi)
{
   BOOL active = getFXInt(&vi->_active, vi->_trail);
   if (active) {
      vi->_initial = vi->_oldDSize._val;                      // Preserve initial size
      vi->_final   = [vi->_theVar domsize];                   // snapshot final size
      assignTRDouble(&vi->_oldDSize,vi->_final,vi->_trail);   // setup final size in current size for next choice down. 
   }
   return active;
}
@end

@implementation CPMonitor
-(id)initCPMonitor:(CPSolverI*)fdm vars:(id<CPVarArray>)allVars
{
   self = [super initCPCoreConstraint];
   _fdm = fdm;
   _monVar    = allVars;
   _nbVI = [_monVar count];
   _nbActive = 0;
   _curActive = malloc(sizeof(CPVarInfo*)*_nbVI);
   _varInfo   = malloc(sizeof(CPVarInfo*)*_nbVI);
   return self;
}
-(void)dealloc
{
   for(CPUInt i=0;i<_nbVI;i++)
      [_varInfo[i] release];
   free(_varInfo);
   free(_curActive);
   [super dealloc];
}
-(CPStatus) post
{
   CPTrail* trail = [_fdm trail];
   CPUInt nbW = 0;
   for(CPInt k = [_monVar low];k <= [_monVar up];k++) {
      id obj = [_monVar at:k];
      CPVarInfo* vInfo = [[CPVarInfo alloc] initCPVarInfo:obj trail:trail];
      _varInfo[nbW++] = vInfo; // [ldm] vInfo is in the _varInfo dico with refcnt = 1 from here on.
      [obj whenChangeDo: ^ { makeVarActive(vInfo);}
               priority: LOWEST_PRIO+1
               onBehalf: self]; 
   }
   [[_fdm propagateDone] wheneverNotifiedDo:^{
      _nbActive = 0;
      for(CPUInt i=0;i<_nbVI;i++) {
         CPVarInfo* vInfo = _varInfo[i];
         if (refresh(vInfo))
            _curActive[_nbActive++] = vInfo;
      }
      //NSLog(@"Monitor was notified of propagDONE: %@",[_curActive description]);
   }];
   return CPSuspend;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:512] autorelease];
   [buf appendString:@"{"];
   [self scanActive:^(CPVarInfo* vi) {
      [buf appendFormat:@"%@,",[vi description]];
   }];
   [buf appendString:@"}"];
   return buf;
}
-(double)reduction
{
   double product = 1.0;
   for(CPUInt k = 0;k<_nbActive;k++)
      product *= _curActive[k]->_final / _curActive[k]->_initial;
   return product;
}
-(double)reductionFromRoot
{
   double product = 1.0;
   for(CPUInt i=0;i<_nbVI;i++) {
      CPVarInfo* vInfo = _varInfo[i];
      product *= vInfo->_final / vInfo->_root;
   }
   return product;   
}
-(void)scanActive:(void(^)(CPVarInfo*))block
{
   for(CPUInt i=0;i<_nbActive;i++) 
      block(_curActive[i]);   
}
@end
