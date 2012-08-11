/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "objcp/CPFactory.h"
#import "objcp/CPController.h"

@class CPIntVarI;

enum CPDomValue {
   Required = 0,
   Possible = 1,
   Removed  = 2
};

@interface CPViewController : ORDefaultController {
   ORClosure _onChoose;
   ORClosure _onFail;
}
-(CPViewController*)initCPViewController:(id<ORSearchController>)chain onChoose:(ORClosure)onc onFail:(ORClosure)onf;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
@end

@interface CPFactory (Visualize)
+(id<CPConstraint>)watchVariable:(id<ORIntVar>)x 
                     onValueLost:(ORInt2Void)lost 
                     onValueBind:(ORInt2Void)bind 
                  onValueRecover:(ORInt2Void)rec 
                   onValueUnbind:(ORInt2Void)unb;
@end

