/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <objcp/CPTopDownMDD.h>

@interface CPMDDWithoutArcs : CPMDD
-(void) DEBUGTestParentChildParity;
@end
@interface CPMDDRestrictionWithoutArcs : CPMDDRestriction
-(void) DEBUGTestParentChildParity;
@end
@interface CPMDDRelaxationWithoutArcs : CPMDDRelaxation {
@private
    SEL _batchMergeStatesSel;
    BatchMergeStatesIMP _batchMergeStates;
}
-(void) DEBUGTestParentChildParity;
@end
