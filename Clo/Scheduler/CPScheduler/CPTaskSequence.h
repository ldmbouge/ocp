/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

@protocol CPTaskVarArray;
@protocol CPTaskVar;
@protocol CPResourceArray;

@interface CPTaskSequence : CPCoreConstraint {
   id<CPTaskVarArray> _tasks;   // TaskVar
   id<CPIntVarArray>  _succ;    // Successors
}
-(id) initCPTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
-(void) dealloc;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end

@interface CPOptionalTaskSequence : CPCoreConstraint {
    id<CPTaskVarArray> _tasks;  // TaskVar
    id<CPIntVarArray>  _succ;   // Successors
}
-(id) initCPOptionalTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ;
-(id) initCPOptionalTaskSequence: (id<CPTaskVarArray>) tasks successors: (id<CPIntVarArray>) succ resource:(id<CPResourceArray>) resource;
-(void) dealloc;
-(void) post;
-(void) propagate;
-(NSSet*) allVars;
-(ORUInt) nbUVars;
@end
