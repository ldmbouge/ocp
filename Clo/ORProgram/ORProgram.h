/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/CPProgram.h>
#import <ORProgram/ORProgramFactory.h>
#import <ORProgram/CPHeuristic.h>
#import "CPBitVarHeuristic.h"
#import <ORProgram/CPDDeg.h>
#import <ORProgram/CPDeg.h>
#import <ORProgram/CPWDeg.h>
#import <ORProgram/CPIBS.h>
#import <ORProgram/CPABS.h>
#import <ORProgram/CPBitVarABS.h>
#import <ORProgram/CPBitVarIBS.h>
#import <ORProgram/CPFirstFail.h>
#import <ORProgram/CPBitVarFirstFail.h>

@interface ORGamma (Model)
-(void) initialize: (id<ORModel>) model;
@end

