/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "LSPropagator.h"
#import <objls/LSFactory.h>

@interface LSVarElement : LSPropagator {  // y[i] = v[x[i]]      \forall i \in range(x)
   id<LSIntVarArray> _x;
   id<LSIntVarArray> _v;
   id<LSIntVarArray> _y;
}
-(id)init: (id<LSIntVarArray>)x of:(id<LSIntVarArray>)v is:(id<LSIntVarArray>)y;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end


@interface LSGElement : LSPropagator {  // y[i] = c[x[i]] \forall i \in D(x)
   id<LSIntVarArray> _x;
   id<LSIntVarArray> _c;
   id<LSIntVarArray> _y;
}
-(id)init:(id<LSEngine>)engine count:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end


@interface LSFactory (LSElement)
+(LSGElement*) element: (id<LSIntVarArray>)x of:(id<LSIntVarArray>)v is:(id<LSIntVarArray>)y;
+(LSGElement*)gelt:(id<LSEngine>)e x:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c result:(id<LSIntVarArray>)y;
@end

