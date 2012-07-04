/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPAssignmentI.h"
#import "CPBasicConstraint.h"
#import "CPSolverI.h"
#import "CPIntVarI.h"
#import "CPArrayI.h"
#import "CPError.h"

@implementation CPAssignment

-(void) initInstanceVariables 
{
    _idempotent = YES;
    _priority = HIGHEST_PRIO-4;
    _posted = false;
}

-(CPAssignment*) initCPAssignment: (CPIntVarArrayI*) x matrix: (CPIntMatrixI*) matrix
{
    self = [super initCPActiveConstraint: [[x cp] solver]];
    _x = x;
    _matrix = matrix;
    [self initInstanceVariables];
    return self;
}

-(void) dealloc 
{
    //   NSLog(@"AllDifferent dealloc called ...");
    if (_posted) {
        _var += _low;
        free(_var);
        [super dealloc];
    }
}

-(NSSet*) allVars
{
    if (_posted)
        return [[NSSet alloc] initWithObjects:_var count:_varSize];
    else
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: allVars called before the constraints is posted"];
    return NULL;
}

-(CPUInt) nbUVars
{
    if (_posted) {
        CPUInt nb=0;
        for(CPUInt k=0;k<_varSize;k++)
            nb += ![_var[k] bound];
        return nb;
    }
    else 
        @throw [[ORExecutionError alloc] initORExecutionError: "Alldifferent: nbUVars called before the constraints is posted"];
    return 0;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_matrix];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _matrix = [aDecoder decodeObject];
    [self initInstanceVariables];
    return self;
}

-(CPStatus) post
{
    if (_posted)
        return CPSuspend;
    _posted = true;
    
    id<CP> cp = [_x cp];
    _low = [_x low];
    _up = [_x up];
    _varSize = (_up - _low + 1);
    _var = malloc(_varSize * sizeof(CPIntVarI*));
    for(CPInt i = 0; i < _varSize; i++) 
        _var[i] = (CPIntVarI*) [_x at: _low + i];
    _var -= _low;
    
    CPRange Rows = [_matrix range: 0];
    CPRange Columns = [_matrix range: 1];
    _lowr = Rows.low;
    _upr = Rows.up;
    _lowc = Columns.low;
    _upc = Columns.up;
    
    if ((_low != _lowr) || (_up != _upr))
        @throw [[ORExecutionError alloc] initORExecutionError: "Assignment: The range of the variables does not agree with the rows of the matrix"];
    
    _cost = [CPFactory TRIntMatrix: cp range: Rows : Columns ];
    _bigM = 0;
    for(CPInt i = _lowr; i <= _upr; i++) 
        for(CPInt j = _lowc; j <= _upc; j++) {
            CPInt v = [_matrix at: i : j ];
            [_cost set: v at: i : j];
            if (v > _bigM)
                _bigM = v;
        }
    _bigM = (_varSize) * (_bigM + 1);
    
   [self preprocess];
        
    _lc = [CPFactory TRIntArray: cp range: Columns];
    _lr = [CPFactory TRIntArray: cp range: Rows];
    for(CPInt i = _lowc; i <= _upc; i++)
        [_lc set: 0 at: i];
    for(CPInt i = _lowr; i <= _upr; i++)
        [_lr set: 0 at: i];
    
    _rowOfColumn = [CPFactory TRIntArray: cp range: Columns];
    _columnOfRow = [CPFactory TRIntArray: cp range: Rows];
    for(CPInt i = _lowc; i <= _upc; i++)
        [_rowOfColumn set: MAXINT at: i];
    for(CPInt i = _lowr; i <= _upr; i++)
        [_columnOfRow set: MAXINT at: i];
    
    _columnIsMarked = (CPInt*) malloc(sizeof(CPInt) * (_upc - _lowc + 1));
    _columnIsMarked -= _lowc;
    
    _rowIsMarked = (CPInt*) malloc(sizeof(CPInt) * (_upr - _lowr + 1));
    _rowIsMarked -= _lowr;
    
    _pathRowOfColumn = (CPInt*) malloc(sizeof(CPInt) * (_upc - _lowc + 1));
    _pathRowOfColumn -= _lowc;
    
    _pi = (CPInt*) malloc(sizeof(CPInt) * (_upc - _lowc + 1));
    _pi -= _lowc;
    
    [self reduceCostMatrix];
    [self greedyAssignment];
    [self printCostMatrix];
    printf("\n");
    [self printReducedCostMatrix];
    printf("\n");
    [self printAssignment];
       
   [self propagate];
    for(CPInt k = 0 ; k < _varSize; k++)
        if (![_var[k] bound])
            [_var[k] whenChangePropagate: self];
    return CPSuspend;
}

-(void) preprocess
{   
    for(CPInt i = _lowr; i <= _upr; i++) {
       [_var[i] updateMin: _lowc];
       [_var[i] updateMax: _upc];
    }
    for(CPInt i = _lowr; i <= _upr; i++) 
        for(CPInt v = _lowc; v <= _upc; v++)
            if (![_var[i] member: v])
                [_cost set: _bigM at: i : v];
}

-(void) propagate
{   
    [self findAssignment];
    [self prune];
}

-(void) findAssignment
{
    for(CPInt i = _lowr; i <= _upr; i++) 
        if (!assignedRow(self,i))
            [self applyAugmentingPathFrom: i to: [self findAugmentingPathFrom: i]];
}

-(CPStatus) prune
{   
    return CPSuspend;
}

-(void) applyAugmentingPathFrom: (CPInt) i to: (CPInt) j
{
    
}
-(CPInt) findAugmentingPathFrom: (CPInt) i 
{
    return 0;
}
-(void) printCostMatrix
{
    printf("      ");
    for(CPInt j = _lowc; j <= _upc; j++)
        printf("%2d ",[_lc at: j]);
    printf("\n");
    for(CPInt i = _lowr; i <= _upr; i++) {
        printf("%2d  : ",[_lr at: i]);
        for(CPInt j = _lowc; j <= _upc; j++)
            printf("%2d ",[_cost at: i : j]);
        printf("\n");
    }
}
-(void) printReducedCostMatrix
{
    printf("      ");
    for(CPInt j = _lowc; j <= _upc; j++)
        printf("%2d ",[_lc at: j]);
    printf("\n");
    for(CPInt i = _lowr; i <= _upr; i++) {
        printf("%2d  : ",[_lr at: i]);
        for(CPInt j = _lowc; j <= _upc; j++)
            printf("%2d ",[_cost at: i : j] - [_lc at: j] - [_lr at: i]);
        printf("\n");
    }
}

-(void) printAssignment
{
    printf("     ");
    for(CPInt j = _lowc; j <= _upc; j++) {
        CPInt asg = [_rowOfColumn at: j];
        if (asg != MAXINT)
            printf("%2d ",asg);
        else 
            printf("   ");
    }
    printf("\n");
    for(CPInt i = _lowr; i <= _upr; i++) {
        CPInt asg = [_columnOfRow at: i];
        if (asg != MAXINT)
            printf("%2d : ",asg);
        else 
            printf("   : ");
        for(CPInt j = _lowc; j <= _upc; j++) 
            printf("%2d ",[_cost at: i : j]);
        printf("\n");
    }
    printf("\n");
    for(CPInt j = _lowc; j <= _upc; j++) 
        printf("Row of column %d is %d \n",j,[_rowOfColumn at: j]);
    printf("\n");
    
    for(CPInt i = _lowr; i <= _upr; i++) 
        printf("Column of row %d is %d \n",i,[_columnOfRow at: i]);
    printf("\n");
    
}

-(void) reduceCostMatrix
{
    for(CPInt j = _lowc; j <= _upc; j++) {
        CPInt min = _bigM;
        CPInt lcj = [_lc at: j];
        for(CPInt i = _lowr; i <= _upr; i++) {
            int v = [_cost at: i : j] - [_lr at: i] - lcj;
            if (v < min)
                min = v;
        }
        [_lc set: lcj + min at: j];
    }
    for(CPInt i = _lowr; i <= _upr; i++) {
        CPInt min = _bigM;
        CPInt lri = [_lr at: i];
        for(CPInt j = _lowc; j <= _upc; j++) {
            int v = [_cost at: i : j] - lri - [_lc at: j];
            if (v < min)
                min = v;
        }
        [_lr set: lri + min at: i];
    }
}

static inline BOOL assignedColumn(CPAssignment* cstr,CPInt j)
{
    return [cstr->_rowOfColumn at: j] != MAXINT;
}
static inline BOOL assignedRow(CPAssignment* cstr,CPInt i)
{
    return [cstr->_columnOfRow at: i] != MAXINT;
}
static inline void assignRow(CPAssignment* cstr,CPInt i,CPInt j)
{
    [cstr->_columnOfRow set: j at: i];
    [cstr->_rowOfColumn set: i at: j];
}
-(void) greedyAssignment
{
    for(CPInt i = _lowr; i <= _upr; i++) 
        for(CPInt j = _lowc; j <= _upc; j++) 
            if (!assignedColumn(self,j)) 
                if ([_cost at: i : j] - [_lc at: j] - [_lr at: i] == 0) {
                    assignRow(self,i,j);  
                    break;
                }
}
@end

