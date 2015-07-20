/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORModeling/ORModeling.h>

@protocol CPCommonProgram;
@protocol ORAnnotation;
@protocol CPEngine;

@interface ORCPConcretizer  : ORVisitor<NSObject> {
   id<CPCommonProgram> _solver;
   id<CPEngine>        _engine;
   id __unsafe_unretained* _gamma;
   id<ORAnnotation>    _notes;
}
-(ORCPConcretizer*) initORCPConcretizer:(id<CPCommonProgram>) solver
                             annotation:(id<ORAnnotation>)notes;
-(BOOL)isConcretized:(id<ORObject>)obj;
-(BOOL)mustConcretize:(id<ORObject>)obj;
-(id)gamma:(id<ORObject>)obj;
@end

@interface ORCPSearchConcretizer : ORVisitor<NSObject>
-(ORCPSearchConcretizer*) initORCPConcretizer: (id<CPEngine>) engine
                                        gamma:(id<ORGamma>)gamma;
@end
