/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2013-14 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@protocol CPTaskVarArray;
@protocol CPTaskVar;

@interface CPTaskSequence : CPCoreConstraint {
   id<CPTaskVarArray>  _tasks;   // TaskVar
   id<CPIntVarArray>  _succ;   // TaskVar
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPOptionalTaskSequence : CPCoreConstraint {
    id<CPTaskVarArray>  _tasks;   // TaskVar
    id<CPIntVarArray>  _succ;   // TaskVar
}
-(id) initCPOptionalTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
-(void) dealloc;
-(ORStatus) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
