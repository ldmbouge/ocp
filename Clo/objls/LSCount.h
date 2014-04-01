/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "LSPropagator.h"
#import <objls/LSFactory.h>

@interface LSCount : LSPropagator {
   id<ORIdArray>  _src;
   id<ORIdArray>  _cnt;
   id<ORIntArray> _old;
}
-(id)init:(id<LSEngine>)engine count:(id<ORIdArray>)src card:(id<ORIdArray>)cnt;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end

@interface LSWeightedCount : LSPropagator {
   id<LSIntVarArray>  _src;
   id<LSIntVarArray>  _cnt;
   id<ORIntArray>     _w;
   id<ORIntArray>     _old;
}
-(id)init: (id<LSIntVarArray>) src weight: (id<ORIntArray>)w count:(id<LSIntVarArray>)cnt;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end

@interface LSInv : LSPropagator {  // x <- fun(src)
   NSArray* _src;
   ORInt (^_fun)();
   LSIntVar* _x;
}
-(id)init:(id<LSEngine>)engine var:(id<LSVar>)x equal:(ORInt(^)())fun src:(NSArray*)vars;
-(void)define;
-(void)post;
-(void)execute;
@end

@interface LSSum : LSPropagator {
   id<LSIntVarArray>   _terms;
   LSIntVar*           _sum;
   id<ORIntArray>      _old;
}
-(id)init:(id<LSEngine>)engine sum:(id<LSIntVar>)x array:(id<LSIntVarArray>)terms;
-(void)define;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end

@interface LSScaledSum : LSPropagator {
   id<ORIntArray>      _coefs;
   id<LSIntVarArray>   _terms;
   LSIntVar*           _sum;
   id<ORIntArray>      _old;
   
}
-(id)init:(id<LSEngine>)engine sum:(id<LSIntVar>)x coefs:(id<ORIntArray>)c array:(id<LSIntVarArray>)terms;
-(void)define;
-(void)post;
-(id<NSFastEnumeration>)outbound;
@end


@interface LSFactory (LSGlobalInvariant)
+(LSCount*)count:(id<LSEngine>)engine vars:(id<LSIntVarArray>)x card:(id<LSIntVarArray>)c;
+(LSInv*)inv:(id<LSIntVar>)x equal:(ORInt(^)())fun vars:(NSArray*)av;
+(LSSum*)sum:(id<LSIntVar>)x over:(id<LSIntVarArray>)terms;
+(LSScaledSum*)sum:(id<LSIntVar>)x is:(id<ORIntArray>)c times:(id<LSIntVarArray>)terms;
@end