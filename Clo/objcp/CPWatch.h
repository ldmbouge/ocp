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

@interface CPViewController : CPDefaultController {
   CPClosure _onChoose;
   CPClosure _onFail;
}
-(CPViewController*)initCPViewController:(id<CPSearchController>)chain onChoose:(CPClosure)onc onFail:(CPClosure)onf;
-(CPInt)  addChoice: (NSCont*) k;
-(void)       fail;
@end

@interface CPFactory (Visualize)
+(id<CPConstraint>)watchVariable:(id<CPIntVar>)x 
                     onValueLost:(CPInt2Void)lost 
                     onValueBind:(CPInt2Void)bind 
                  onValueRecover:(CPInt2Void)rec 
                   onValueUnbind:(CPInt2Void)unb;
@end

