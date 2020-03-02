/************************************************************************
 Mozilla Public License

 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPTopDownMDD.h"

@interface CPMDDWithArcs : CPMDD
@end
@interface CPMDDRestrictionWithArcs : CPMDDRestriction
@end
@interface CPMDDRelaxationWithArcs : CPMDDRelaxation {
@protected
    SEL _replaceArcStateSel;
    ReplaceArcStateIMP _replaceArcState;
}
-(void) recalcArc:(MDDArc*)arc parentPropertes:(char*)parentProperties variable:(int)variable;
-(void) DEBUGTestParentArcIndices;
@end
