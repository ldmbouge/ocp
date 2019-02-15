/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <Foundation/NSObject.h>

// PVH 
// CPEngine is a protocol; to be renamed in CPSolver
// CPSolver to necome CPSolverI

// PVH to change when the CPEngine is done.

#import "CPData.h"

// PVH TO FIX
@class CPSolver;
// PVH TO FIX
@class CPExpr;

typedef void (^CPClosure)(void);
typedef bool (^CPInt2Bool)(int);
typedef bool (^CPVoid2Bool)(void);
typedef int (^CPInt2Int)(int);
typedef void (^CPInt2Void)(int);
typedef int (^CPIntxInt2Int)(int,int);
typedef CPExpr* (^CPInt2Expr)(int);

typedef struct CPBounds {
    int min;
    int max;
} CPBounds;

typedef enum  {
    CPFailure,
    CPSuccess,
    CPSuspend,
    CPDelay,
    CPSkip
} CPStatus;

typedef CPStatus (^ConstraintCallback)(void);
typedef CPStatus (^ConstraintIntCallBack)(int);


@protocol CPCommand <NSObject,NSCoding>
-(CPStatus) doIt;
@end

@protocol CPConstraint <NSObject,CPCommand>
-(CPStatus) post;
@end


@protocol CPIntVar <NSObject>
-(BOOL) bound;
-(int)  min;
-(int)  max;
-(void) bounds: (CPBounds*) bnd;
-(int)  domsize;
-(bool) member: (int) v;
// PVH to change
-(CPSolver*) solver;
@end


@protocol CPEngine <NSObject> 
-(void)        saveSolution;
-(void)     restoreSolution;
//PVH to FIX
//-(void)                push: (id<CPSearchController>) c;
-(void)      nestedMinimize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)      nestedMaximize: (id<CPIntVar>) x in: (CPClosure) body onSolution: onSolution onExit: onExit;
-(void)            forrange: (CPRange) range filteredBy: (CPInt2Bool) f orderedBy: (CPInt2Int) o do: (CPInt2Void) b;
-(void)                 try: (CPClosure) left or: (CPClosure) right;
-(void)              tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body; 
-(void)              tryall: (CPRange) range filteredBy: (CPInt2Bool) f in: (CPInt2Void) body onFailure: (CPInt2Void) onFailure;
-(void)                post: (id<CPConstraint>) c;
-(void)               label: (id<CPIntVar>) var with: (int) val;
-(void)                diff: (id<CPIntVar>) var with: (int) val;


-(void)              search: (CPClosure) body;
-(void)               solve: (CPClosure) body;
-(void)               solve: (CPClosure) body using:(CPClosure) search;
-(void)            solveAll: (CPClosure) body;
-(void)            solveAll: (CPClosure) body using:(CPClosure) search;
-(void)            minimize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            maximize: (id<CPIntVar>) x in: (CPClosure) body;
-(void)            minimize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;
-(void)            maximize: (id<CPIntVar>) x subjectTo: (CPClosure) body using:(CPClosure) search;

-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)         nestedSolve: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)         nestedSolve: (CPClosure) body;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution onExit: (CPClosure) onExit;
-(void)      nestedSolveAll: (CPClosure) body onSolution: (CPClosure) onSolution;
-(void)      nestedSolveAll: (CPClosure) body;

-(void)                once: (CPClosure) cl;
-(void)      limitSolutions: (int) maxSolutions in: (CPClosure) cl;
-(void)  limitDiscrepancies: (int) maxDiscrepancies in: (CPClosure) cl;
-(void)             restart: (CPClosure) body onRestart: (CPClosure) onRestart isDone: (CPVoid2Bool) isDone;
@end
