/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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
-(id)initCPMonitor:(CPSolverI*)fdm vars:(NSArray*)allVars
{
   self = [super initCPCoreConstraint];
   _fdm = fdm;
   _monVar    = [allVars retain];
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
   [_monVar release];
   [super dealloc];
}
-(CPStatus) post
{
   CPTrail* trail = [_fdm trail];
   CPUInt nbW = 0;
   for(id obj in _monVar) {
      CPVarInfo* vInfo = [[CPVarInfo alloc] initCPVarInfo:obj trail:trail];
      _varInfo[nbW++] = vInfo; // [ldm] vInfo is in the _varInfo dico with refcnt = 1 from here on.
      [obj whenChangeDo: ^CPStatus{ makeVarActive(vInfo);return CPSuspend;}
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
