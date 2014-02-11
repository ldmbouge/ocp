/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/


#import "LSPropagator.h"
#import "LSFactory.h"

@interface LSCount : LSPropagator<LSPull> {
   id<ORIdArray>  _src;
   id<ORIdArray>  _cnt;
   id<ORIntArray> _old;
}
-(id)init:(id<LSEngine>)engine count:(id<ORIdArray>)src card:(id<ORIdArray>)cnt;
-(void)post;
-(void)pull:(ORInt)k;
-(id<NSFastEnumeration>)outbound;
@end

@interface LSFactory (LSGlobalInvariant)
+(LSCount*)count:(id<LSEngine>)engine vars:(id<ORIdArray>)x card:(id<ORIdArray>)c;
+(id)inv:(LSIntVar*)x equal:(ORInt(^)())fun vars:(NSArray*)av;
@end