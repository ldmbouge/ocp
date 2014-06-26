/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2014 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <objls/LSSolver.h>
#import <objls/LSEngine.h>

@interface ORLSConcretizer  : ORVisitor<NSObject>
{
   id<LSProgram>        _solver;
   id<LSEngine>         _engine;
   id*                   _gamma;
   id<ORAnnotation>      _notes;
   NSMutableArray*    _allCstrs;
   NSMutableArray*   _hardCstrs;
   id<LSConstraint>  _objective;
}
-(ORLSConcretizer*) initORLSConcretizer: (id<LSProgram>) solver annotation:(id<ORAnnotation>)notes;
-(id<LSConstraint>)wrapUp;
-(NSMutableArray*)hardSet;
@end

