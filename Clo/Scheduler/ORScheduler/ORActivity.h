/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>


// [pvh: will need to see if this is needed]

    // Different activity types
    // NOTE: Last bit represents indicates whether the activity is optional or
    //  compulsory
typedef enum {
    ORACTCOMP  = 0,   // Standard compulsory activity
    ORACTOPT   = 1,   // Standard optional activity
    ORALTCOMP  = 2,   // Compositional compulsory activity by alternative constraint
    ORALTOPT   = 3,   // Compositional optional activity by alternative constraint
    ORSPANCOMP = 4,   // Compositional compulsory activity by span constraint
    ORSPANOPT  = 5    // Compositional optional activity by span constraint
} ORActivityType;

@protocol ORPrecedes;

