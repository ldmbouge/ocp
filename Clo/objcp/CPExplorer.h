/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>

@class Checkpoint;

@protocol CPExplorer <NSObject>
-(void)                push: (id<CPSearchController>) c;

// Statistics
-(CPInt)       nbChoices;
-(CPInt)       nbFailures;

// access 
-(id<CPSearchController>)    controller;
-(void)                   setController: (id<CPSearchController>) controller;
-(void)addHeuristic:(id<CPHeuristic>)h;

// top level calls
-(void)              search: (CPClosure) body;
-(void)               solve: (CPClosure) body;
-(void)            solveAll: (CPClosure) body;
-(void)               solve: (CPClosure) body using: (CPClosure) search;
-(void)            solveAll: (CPClosure) body using: (CPClosure) search;
// combinators
-(void)        nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc;
-(void)     nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit control:(id<CPSearchController>)sc;
-(void)           forrange: (CPRange) range filteredBy: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                try: (CPClosure) left or: (CPClosure) right;
-(void)             tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body;
-(void)             tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
-(void)               fail;
-(void)            repeat: (CPClosure) body onRepeat: (CPClosure) onRepeat until: (CPVoid2Bool) isDone;
-(void)           optimize: (CPClosure) body post: (CPClosure) post canImprove: (CPVoid2CPStatus) canImprove update: (CPClosure) update;
-(void)           optimize: (CPClosure) body post: (CPClosure) post canImprove: (CPVoid2CPStatus) canImprove update: (CPClosure) update 
                onSolution: (CPClosure) onSolution 
                    onExit: (CPClosure) onExit;
@optional 
-(void)               once: (CPClosure) cl;
-(void)    applyController: (id<CPSearchController>) controller in: (CPClosure) cl;
-(void)     limitSolutions: (CPInt) maxSolutions in: (CPClosure) cl;
-(void)     limitCondition: (CPVoid2Bool) condition in: (CPClosure) cl;
-(void) limitDiscrepancies: (CPInt) maxDiscrepancies in: (CPClosure) cl;
-(void)      limitFailures: (CPInt) maxFailures in: (CPClosure) cl;
-(void)          limitTime: (CPLong) maxTime in: (CPClosure) cl;
-(CPStatus)restoreCheckpoint:(Checkpoint*)cp;
-(Checkpoint*)captureCheckpoint;
-(NSData*)packCheckpoint:(Checkpoint*)cp;
-(NSData*)captureAndPackProblem;
@end

