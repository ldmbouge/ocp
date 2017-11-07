/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORUtilities/cont.h>
#import <ORFoundation/ORController.h>
#import <ORFoundation/ORTracer.h>

@protocol ORChoiceHeuristic
-(double)lastChoiceRating;
@end

@interface ORSemFDSController : ORDefaultController <NSCopying,ORSearchController,ORStealing>
-(id) initTheController:(id<ORTracer>)tracer engine:(id<ORSearchEngine>)engine posting:(id<ORPost>)model heuristic:(id<ORChoiceHeuristic>)h;
-(void) dealloc;
-(void) setup;
-(void) cleanup;
-(ORInt) addChoice:(NSCont*)k;
-(void) trust;
-(void) fail;
-(ORHeist*)steal;
@end
