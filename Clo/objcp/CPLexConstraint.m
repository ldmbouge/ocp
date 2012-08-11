/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPLexConstraint.h"
#import "objcp/CP.h"
#import "objcp/CPError.h"
#import "CPIntVarI.h"

@implementation CPLexConstraint {
   TRInt          _q; // index of q symbol in string
   TRInt          _r; // index of r symbol in string
   TRInt          _s; // index of s symbol in string
   TRInt          _u; // identifier of state we are in (incremental)
   CPIntVarI**   _xa; // 0-based version of _x
   CPIntVarI**   _ya; // 0-based version of _y
   CPULong       _sz; // size of xa/ya
   id<CPEngine> _fdm;
}
-(id) initCPLexConstraint:(id<ORIntVarArray>)x and:(id<ORIntVarArray>)y
{
   self = [super initCPActiveConstraint:[[x cp] solver]];
   _x = x;
   _y = y;
   _fdm = [[x cp] solver];
   if ([_x count] != [_y count])
      @throw [[CPInternalError alloc] initCPInternalError:"incompatible sizes in lex constraint"];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}

#define LEX_XEQ_GEQY(i) (minDom(_xa[(i)]) == maxDom(_ya[(i)]))
#define LEX_XEQ_LEQY(i) (maxDom(_xa[(i)]) == minDom(_ya[(i)]))
#define LEX_XLY(i)      (maxDom(_xa[(i)]) < minDom(_ya[(i)]))
#define LEX_XEQY(i)     (bound(_xa[(i)]) && bound(_ya[(i)]) && minDom(_xa[(i)]) == minDom(_ya[(i)]))
#define LEX_XGY(i)      (minDom(_xa[(i)]) > maxDom(_ya[(i)]))
#define LEX_XLEQY(i)    (maxDom(_xa[(i)]) == minDom(_ya[(i)]) && minDom(_xa[(i)]) < maxDom(_ya[(i)]))
#define LEX_XGEQY(i)    (maxDom(_ya[(i)]) == minDom(_xa[(i)]) && minDom(_ya[(i)]) < maxDom(_xa[(i)]))
#define LEX_Q           (_q._val)
#define LEX_R           (_r._val)
#define LEX_S           (_s._val)
#define STATE           (_u._val)

-(void)propagateFrom:(CPInt)k
{
   if (_active._val == NO) return;
   CPLong up = _sz - 1;
   CPInt  i = k;
   if (k == LEX_Q) goto STATE1;
   else if (k == LEX_R) goto STATE2;
   else if (STATE == 3 && (k == LEX_S || (k < LEX_S && maxDom(_xa[k]) != minDom(_ya[k])))) goto STATE3;
   else if (STATE == 4 && (k == LEX_S || (k < LEX_S && minDom(_xa[k]) != maxDom(_ya[k])))) goto STATE4;
   else return;
STATE1:
   while (i <= up && LEX_XEQ_GEQY(i)) { // STATE 1 (x_i = y_i OR x_i >= y_i)
      CPInt xi = minDom(_xa[i]);
      [_xa[i] bind:xi];
      [_ya[i] bind:xi];
      i = i + 1;
   }
   assignTRInt(&_q,i,_trail);  // update Q to point to the first symbol s.t. x_q ? y_q
   if (i > up || LEX_XLY(i)) {
      assignTRInt(&_active,NO,_trail);
      return;        // STATE T1. We added the requirements on P.
   }
   // transition 1 -> 2
   // q is now pointing to the ? :  x_q <= y_q
   [_xa[LEX_Q] updateMax: maxDom(_ya[LEX_Q])];
   [_ya[LEX_Q] updateMin: minDom(_xa[LEX_Q])];
   assignTRInt(&_r,i = max(i+1,LEX_R),_trail);
STATE2:
   while(i <= up && LEX_XEQY(i))  // stay in STATE 2
      i = i + 1;
   assignTRInt(&_r,i,_trail);   
   if (i > up || LEX_XLY(i)) { // transition STATE 2 -> T3
      assignTRInt(&_active,NO,_trail);
      if (bound(_ya[LEX_Q]))
         [_xa[LEX_Q] updateMax: minDom(_ya[LEX_Q])];
      else {
         [_fdm post:[CPFactory lEqual:_xa[LEX_Q] to:_ya[LEX_Q]]];               // T3: INFER: x_q <= y_q
      }
   } else if (LEX_XGY(i)) {    // transition STATE 2 -> T2
      assignTRInt(&_active,NO,_trail);
      if (bound(_ya[LEX_Q]))
         [_xa[LEX_Q] updateMax: minDom(_ya[LEX_Q])-1];
      else {
         [_fdm post:[CPFactory lEqual:_xa[LEX_Q]
                                   to:[CPFactory intVar:_ya[LEX_Q] shift:-1]]]; // T2: INFER: x_q < y_q
      }
   } else if (LEX_XLEQY(i)) {  // transition STATE 2 -> STATE 3
      assignTRInt(&_s,i = max(i + 1,LEX_S),_trail);
      goto STATE3;
   } else if (LEX_XGEQY(i)) {  // transition 2 -> 4
      assignTRInt(&_s,i = max(i + 1,LEX_S),_trail);
      goto STATE4;
   } else {                           // ****************** ENTERING STATE D1
      assignTRInt(&_u,2,_trail);      // remember we were in state 2 (where to resume).
   }
STATE3:
   // ****************** ENTERING STATE 3
   while(i <= up && LEX_XEQ_LEQY(i))
      i = i+1;
   assignTRInt(&_s,i,_trail);
   if (i>up || LEX_XLY(i)) {   // transition STATE 3 -> T3
      assignTRInt(&_active,NO,_trail);
      if (bound(_ya[LEX_Q]))
         [_xa[LEX_Q] updateMax: minDom(_ya[LEX_Q])];
      else {
         [_fdm post:[CPFactory lEqual:_xa[LEX_Q] to:_ya[LEX_Q]]]; // T3: INFER x_q <= y_q
      }
   }
   // transition 3 -> D3
   // ****************** ENTERING STATE D3
   assignTRInt(&_u,3,_trail);
STATE4:
   // ****************** ENTERING STATE 4
   while(i<=up && LEX_XEQ_GEQY(i))
      i = i + 1;
   assignTRInt(&_s,i,_trail);
   if (i <= up && LEX_XGY(i)) {// transition STATE 4 -> T2
      assignTRInt(&_active,NO,_trail);
      if (bound(_ya[LEX_Q]))
         [_xa[LEX_Q] updateMax: minDom(_ya[LEX_Q])-1];
      else {
         [_fdm post:[CPFactory lEqual:_xa[LEX_Q]
                                   to:[CPFactory intVar:_ya[LEX_Q] shift:-1]]]; // T2: INFER x_q < y_q
      }
   }
   // transition 4 -> D2
   // ****************** ENTERING STATE D2
   assignTRInt(&_u, 4, _trail);
}

-(void) listenFrom:(CPInt)ofs
{
   for(CPInt k=ofs;k<_sz;k++) {
      if (!bound(_xa[k]))
         [_xa[k] whenChangeBoundsDo:^{
            [self propagateFrom:k];
         } onBehalf:self];
      if (!bound(_ya[k]))
         [_ya[k] whenChangeBoundsDo:^{
            [self propagateFrom:k];
         } onBehalf:self];
   }
}


-(ORStatus)post
{
   _q = makeTRInt(_trail, 0);
   _r = makeTRInt(_trail, 0);
   _s = makeTRInt(_trail, 0);
   _u = makeTRInt(_trail, 0);
   _sz = [_x count];
   _xa= malloc(sizeof(CPIntVarI*)*_sz);
   _ya= malloc(sizeof(CPIntVarI*)*_sz);
   for(CPInt k=[_x low]; k<= [_x up];k++) _xa[k - [_x low]] = (CPIntVarI*)_x[k];
   for(CPInt k=[_y low]; k<= [_y up];k++) _ya[k - [_y low]] = (CPIntVarI*)_y[k];
   CPLong up = _sz - 1;
   CPInt  i = 0;
   while (i <= up && LEX_XEQ_GEQY(i)) { // STATE 1 (x_i = y_i OR x_i >= y_i)
      CPInt xi = minDom(_xa[i]);
      [_xa[i] bind:xi];
      [_ya[i] bind:xi];
      i = i + 1;
   }
   assignTRInt(&_q,i,_trail);  // update Q to point to the first symbol s.t. x_q ? y_q
   if (i > up || LEX_XLY(i))
      return ORSuccess;        // STATE T1. We added the requirements on P.
   // transition 1 -> 2
   // q is now pointing to the ? :  x_q <= y_q
   [_xa[LEX_Q] updateMax: maxDom(_ya[LEX_Q])];
   [_ya[LEX_Q] updateMin: minDom(_xa[LEX_Q])];
   i = i+1;
   assignTRInt(&_r,i,_trail);
   // *********** ENTERING STATE 2:
   while(i <= up && LEX_XEQY(i))  // stay in STATE 2
      i = i + 1;
   assignTRInt(&_r,i,_trail);

   if (i > up || LEX_XLY(i)) { // transition STATE 2 -> T3
      return [_fdm post:[CPFactory lEqual:_xa[LEX_Q] to:_ya[LEX_Q]]];               // T3: INFER: x_q <= y_q
   } else if (LEX_XGY(i)) {    // transition STATE 2 -> T2
      return [_fdm post:[CPFactory lEqual:_xa[LEX_Q]
                                       to:[CPFactory intVar:_ya[LEX_Q] shift:-1]]]; // T2: INFER: x_q < y_q
   } else if (LEX_XLEQY(i)) {  // transition STATE 2 -> STATE 3
      assignTRInt(&_s,i = i + 1,_trail);
      // ****************** ENTERING STATE 3
      while(i <= up && LEX_XEQ_LEQY(i))
         i = i+1;
      assignTRInt(&_s,i,_trail);
      if (i>up || LEX_XLY(i))   // transition STATE 3 -> T3
         return [_fdm post:[CPFactory lEqual:_xa[LEX_Q] to:_ya[LEX_Q]]]; // T3: INFER x_q <= y_q
      // transition 3 -> D3
      // ****************** ENTERING STATE D3
      [self listenFrom:LEX_Q];
      assignTRInt(&_u,3,_trail);
      return ORSuspend;
   } else if (LEX_XGEQY(i)) {  // transition 2 -> 4
      assignTRInt(&_s,i = i + 1,_trail);
      // ****************** ENTERING STATE 4
      while(i<=up && LEX_XEQ_GEQY(i))
         i = i + 1;
      assignTRInt(&_s,i,_trail);
      if (i <= up && LEX_XGY(i)) // transition STATE 4 -> T2
         return [_fdm post:[CPFactory lEqual:_xa[LEX_Q]
                                          to:[CPFactory intVar:_ya[LEX_Q] shift:-1]]]; // T2: INFER x_q < y_q
      // transition 4 -> D2
      // ****************** ENTERING STATE D2
      [self listenFrom:LEX_Q];
      assignTRInt(&_u, 4, _trail);
      return ORSuspend;
   } else {
      // ****************** ENTERING STATE D1
      [self listenFrom:LEX_Q];
      assignTRInt(&_u,2,_trail);      // remember we were in state 2 (where to resume).
      return ORSuspend;
   }
}
-(NSSet*)allVars
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:[_x count] + [_y count]];
   for(CPInt k=[_x low];k <= [_x up];k++)
      [rv addObject:_x[k]];
   for(CPInt k=[_y low];k <= [_y up];k++)
      [rv addObject:_y[k]];
   return rv;
}

-(CPUInt)nbUVars
{
   CPUInt nb = 0;
   for(CPInt k=0; k < _sz;k++)
      nb += !bound(_xa[k]);
   for(CPInt k=0; k < _sz;k++)
      nb += !bound(_ya[k]);
   return nb;
}
-(NSString*)description
{
   return [NSMutableString stringWithFormat:@"<CPLexConstraintDC: %02d (%@ <=(lex) %@)>",_name,_x,_y];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}

@end
