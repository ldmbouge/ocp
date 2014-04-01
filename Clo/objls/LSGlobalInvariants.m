/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSCount.h"
#import "LSIntVar.h"
#import "LSGlobalInvariants.h"

typedef struct LSEltNode {
   ORInt _prev;
   ORInt _next;
} LSEltNode;



@implementation LSVarElement {
   ORInt*         _head;
   LSEltNode*     _lists;
   ORInt          _vlb,_vub,_eol;
   ORInt*         _delta;
   ORInt          _ndelta;
   id<ORIntArray> _oldx;
}
-(id)init: (id<LSIntVarArray>)x of:(id<LSIntVarArray>)v is:(id<LSIntVarArray>)y
{
   self = [super initWith: [x[x.range.low] engine]];
   _x = x;
   _v = v;
   _y = y;
   return self;
}
-(void)setup
{
   id<ORIntRange> xr = [_x range];
   _vlb = FDMAXINT;
   _vub = FDMININT;
   for(ORInt i=_x.low;i <= _x.up;i++) {
      ORInt xil = [[_x[i] domain] low];
      ORInt xiu = [[_x[i] domain] up];
      _vlb = xil < _vlb ? xil : _vlb;
      _vub = xiu > _vub ? xiu : _vub;
   }
   _head = malloc(sizeof(ORInt)*(_vub - _vlb+1));
   memset(_head, 0, sizeof(ORInt)*(_vub - _vlb + 1));
   _head -= _vlb;
   _lists = malloc(sizeof(LSEltNode)*[xr size]);
   memset(_lists,0,sizeof(LSEltNode)*[xr size]);
   _lists -= xr.low;
   _eol = xr.low - 1;
   _delta = malloc(sizeof(ORInt)*(_vub - _vlb + 1));
   _ndelta = 0;
}
void printLists(LSVarElement* elt)
{
   for(ORInt i= elt->_vlb;i <= elt->_vub;i++) {
      ORInt cur = elt->_head[i];
      printf("value(%d) : ",i);
      while (cur != elt->_eol) {
         printf("%d:<%d,%d> ",cur,elt->_lists[cur]._prev,elt->_lists[cur]._next);
         cur = elt->_lists[cur]._next;
      }
      printf("\n");
   }
}
-(void)define  // y[i] = v[x[i]] 
{
   [self setup];
   // [pvh] what to do when x changes
   for(ORInt i=_x.low;i <= _x.up;i++)
      [self addTrigger:[_x[i] addListener:self with:^{
         ORInt oi = [_oldx at:i];
         ORInt ni = _x[i].value;
         //Remove node(i) from old list (oi)
         if (_lists[i]._prev != _eol)
            _lists[_lists[i]._prev]._next = _lists[i]._next;
         else
            _head[oi] = _lists[i]._next;
         if (_lists[i]._next != _eol)
            _lists[_lists[i]._next]._prev = _lists[i]._prev;
         // Link node(i) in new list (ni)
         assert(_head[ni] != i);
         _lists[i]._next = _head[ni];
         assert(_lists[i]._next != i);
         _lists[i]._prev = _eol;
         if (_head[ni]!=_eol)
            _lists[_head[ni]]._prev = i;
         _head[ni] = i;
         // update _y[i] right away
         [_y[i] setValue: _v[ni].value];
         // Fixup _oldx
         [_oldx set:ni at:i];
      }]];
   // [pvh] what to do when c changes
   for(ORInt i=_v.low;i <= _v.up;i++)
      [self addTrigger:[_v[i] addListener:self with:^{
         _delta[_ndelta++] = i;
      }]];
   // [pvh] y is listening to the propaator
   for(ORInt i=_y.low;i <= _y.up;i++)
      [_y[i] addDefiner:self];
}
-(void)post
{
   _oldx = [ORFactory intArray:_engine range:[_x range] with:^ORInt(ORInt i) {
      return _x[i].value;
   }];
   for(ORInt i=_x.low;i <= _x.up;i++)
      [_y[i] setValue:_v[_x[i].value].value];
   // Initialize the variable list
   for(ORInt i=_vlb;i <= _vub;i++)
      _head[i] = _eol;
   for(ORInt i=_x.low;i <= _x.up;i++) {
      ORInt xiv = _x[i].value;
      _lists[i]._prev = _eol;
      _lists[i]._next = _head[xiv];
      if (_head[xiv] != _eol)
         _lists[_head[xiv]]._prev = i;
      _head[xiv] = i;
   }
}
// [pvh] propagate
-(void)execute
{
   id<LSIntVar>* xBase = (id*)[(id)_x base];
   id<LSIntVar>* yBase = (id*)[(id)_y base];
   for(ORInt k=0;k<_ndelta;k++) {
      ORInt myList = _head[_delta[k]];
      while(myList != _eol) {
         [yBase[myList] setValue: getLSIntValue(_v[[xBase[myList] value]])];
         myList = _lists[myList]._next;
      }
   }
   _ndelta = 0;
}
-(id<NSFastEnumeration>)outbound
{
   return _y;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSGElement(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end

// [pvh] This is not element; must be cleaned; it is element plus some tests > 0
// [pvh] this is best decomposed into element and then a cardinality test

@implementation LSGElement {
   ORInt*         _head;
   LSEltNode*     _lists;
   ORInt          _vlb,_vub,_eol;
   ORInt*         _delta;
   ORInt          _ndelta;
   id<ORIntArray> _oldx;
}
-(id)init:(id<LSEngine>)engine count:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y
{
   self = [super initWith:engine];
   _x = x;
   _c = c;
   _y = y;
   return self;
}
-(void)setup
{
   id<ORIntRange> xr = [_x range];
   _vlb = FDMAXINT;
   _vub = FDMININT;
   for(ORInt i=_x.low;i <= _x.up;i++) {
      ORInt xil = [[_x[i] domain] low];
      ORInt xiu = [[_x[i] domain] up];
      _vlb = xil < _vlb ? xil : _vlb;
      _vub = xiu > _vub ? xiu : _vub;
   }
   _head = malloc(sizeof(ORInt)*(_vub - _vlb+1));
   memset(_head, 0, sizeof(ORInt)*(_vub - _vlb + 1));
   _head -= _vlb;
   _lists = malloc(sizeof(LSEltNode)*[xr size]);
   memset(_lists,0,sizeof(LSEltNode)*[xr size]);
   _lists -= xr.low;
   _eol = xr.low - 1;
   _delta = malloc(sizeof(ORInt)*(_vub - _vlb + 1));
   _ndelta = 0;
}
void printListsGElement(LSGElement* elt)
{
   for(ORInt i= elt->_vlb;i <= elt->_vub;i++) {
      ORInt cur = elt->_head[i];
      printf("value(%d) : ",i);
      while (cur != elt->_eol) {
         printf("%d:<%d,%d> ",cur,elt->_lists[cur]._prev,elt->_lists[cur]._next);
         cur = elt->_lists[cur]._next;
      }
      printf("\n");
   }
}
-(void)define  // y[i] = c[x[i]] > 0
{
   [self setup];
   // [pvh] what to do when x changes
   for(ORInt i=_x.low;i <= _x.up;i++)
      [self addTrigger:[_x[i] addListener:self with:^{
         ORInt oi = [_oldx at:i];
         ORInt ni = _x[i].value;
         //Remove node(i) from old list (oi)
         if (_lists[i]._prev != _eol)
            _lists[_lists[i]._prev]._next = _lists[i]._next;
         else
            _head[oi] = _lists[i]._next;
         if (_lists[i]._next != _eol)
            _lists[_lists[i]._next]._prev = _lists[i]._prev;
         // Link node(i) in new list (ni)
         assert(_head[ni] != i);
         _lists[i]._next = _head[ni];
         assert(_lists[i]._next != i);
         _lists[i]._prev = _eol;
         if (_head[ni]!=_eol)
            _lists[_head[ni]]._prev = i;
         _head[ni] = i;
         // update _y[i] right away
         [_y[i] setValue: _c[ni].value > 0];
         // Fixup _oldx
         [_oldx set:ni at:i];
      }]];
   // [pvh] what to do when c changes
   for(ORInt i=_c.low;i <= _c.up;i++)
      [self addTrigger:[_c[i] addListener:self with:^{
         _delta[_ndelta++] = i;
      }]];
   // [pvh] y is listening to the propaator
   for(ORInt i=_y.low;i <= _y.up;i++)
      [_y[i] addDefiner:self];
}
-(void)post
{
   _oldx = [ORFactory intArray:_engine range:[_x range] with:^ORInt(ORInt i) {
      return _x[i].value;
   }];
   for(ORInt i=_x.low;i <= _x.up;i++)
      [_y[i] setValue:_c[_x[i].value].value > 0];
   // Initialize the variable list
   for(ORInt i=_vlb;i <= _vub;i++)
      _head[i] = _eol;
   for(ORInt i=_x.low;i <= _x.up;i++) {
      ORInt xiv = _x[i].value;
      _lists[i]._prev = _eol;
      _lists[i]._next = _head[xiv];
      if (_head[xiv] != _eol)
         _lists[_head[xiv]]._prev = i;
      _head[xiv] = i;
   }
}
// [pvh] propagate
-(void)execute
{
   id<LSIntVar>* xBase = (id*)[(id)_x base];
   id<LSIntVar>* yBase = (id*)[(id)_y base];
   for(ORInt k=0;k<_ndelta;k++) {
      ORInt myList = _head[_delta[k]];
      while(myList != _eol) {
         [yBase[myList] setValue: getLSIntValue(_c[[xBase[myList] value]]) > 0];
         myList = _lists[myList]._next;
      }
   }
   _ndelta = 0;
}
-(id<NSFastEnumeration>)outbound
{
   return _y;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<LSGElement(%p) : %d,%@>",self,_name,_rank];
   return buf;
}
@end


@implementation LSFactory (LSElement)
+(LSVarElement*) element:(id<LSIntVarArray>)x of:(id<LSIntVarArray>)v is:(id<LSIntVarArray>)y
{
   id<LSEngine> e = [x[x.range.low] engine];
   LSVarElement* elt = [[LSVarElement alloc] init: x of:v is:y];
   [e trackMutable: elt];
   return elt;
}

+(LSGElement*)gelt:(id<LSEngine>)e x:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y
{
   LSGElement* gi = [[LSGElement alloc] init:e count:x card:c result:y];
   [e trackMutable:gi];
   return gi;
}
@end



