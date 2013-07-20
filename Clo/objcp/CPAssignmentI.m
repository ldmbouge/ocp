/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPAssignmentI.h"
#import "CPBasicConstraint.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPError.h"

@implementation CPAssignment
{
   id<CPEngine>       _engine;
   id<CPIntVarArray>  _x;
   id<ORIntMatrix>    _matrix;
   CPIntVarI**        _var;
   CPIntVarI*         _costVariable;
   
   ORInt              _varSize;
   ORInt              _low;
   ORInt              _up;
   
   ORInt              _lowr;
   ORInt              _upr;
   ORInt              _lowc;
   ORInt              _upc;
   id<ORTRIntMatrix>  _cost;
   
   ORInt              _bigM;
   
   id<ORTRIntArray>   _lc;
   id<ORTRIntArray>   _lr;
   
   id<ORTRIntArray>   _rowOfColumn;
   id<ORTRIntArray>   _columnOfRow;
   
   ORInt*             _columnIsMarked;
   ORInt*             _rowIsMarked;
   ORInt*             _pi;
   ORInt*             _pathRowOfColumn;
   
   bool               _posted;
}

-(void) initInstanceVariables 
{
   _idempotent = YES;
   _priority = HIGHEST_PRIO-4;
   _posted = false;
}

-(CPAssignment*) initCPAssignment: (id<CPEngine>) engine array: (id<CPIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (CPIntVarI*) costVariable
{
   self = [super initCPCoreConstraint: engine];
   _x = x;
   _engine = engine;
   _matrix = matrix;
   _costVariable = costVariable;
   [self initInstanceVariables];
   return self;
}

-(void) dealloc
{
   //   NSLog(@"AllDifferent dealloc called ...");
   if (_posted) {
      _var += _low;
      free(_var);
      // need to fill these guys
      [super dealloc];
   }
}

-(NSSet*) allVars
{
   if (_posted)
      return [[[NSSet alloc] initWithObjects:_var count:_varSize] autorelease];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "Assignment Constraint: allVars called before the constraints is posted"];
   return NULL;
}

-(ORUInt) nbUVars
{
   if (_posted) {
      ORUInt nb=0;
      for(ORUInt k=0;k<_varSize;k++)
         nb += ![_var[k] bound];
      return nb;
   }
   else 
      @throw [[ORExecutionError alloc] initORExecutionError: "Assignment Constraint: nbUVars called before the constraints is posted"];
   return 0;
}

- (void) encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_matrix];
   [aCoder encodeObject:_costVariable];
}

- (id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _matrix = [aDecoder decodeObject];
   _costVariable = [aDecoder decodeObject];
   [self initInstanceVariables];
   return self;
}

-(ORStatus) post
{
   if (_posted)
      return ORSuspend;
   _posted = true;
   
   _low = [_x low];
   _up = [_x up];

   id<ORIntRange> Rows = [_matrix range: 0];
   id<ORIntRange> Columns = [_matrix range: 1];
   _lowr = [Rows low];
   _upr = [Rows up];
   _lowc = [Columns low];
   _upc = [Columns up];
   
   if ((_low != _lowr) || (_up != _upr))
      @throw [[ORExecutionError alloc] initORExecutionError: "Assignment: The range of the variables does not agree with the rows of the matrix"];
   
   _varSize = (_up - _low + 1);
   _var = malloc(_varSize * sizeof(CPIntVarI*));
   _var -= _low;
   for(ORInt i = _lowr; i <= _upr; i++) 
      _var[i] = (CPIntVarI*) [_x at: i];

   
   _cost = [CPFactory TRIntMatrix: _engine range: Rows : Columns ];
   _bigM = 0;
   for(ORInt i = _lowr; i <= _upr; i++) 
      for(ORInt j = _lowc; j <= _upc; j++) {
         ORInt v = [_matrix at: i : j ];
         [_cost set: v at: i : j];
         if (v > _bigM)
            _bigM = v;
      }
   _bigM = (_varSize) * (_bigM + 1);
   
   [self preprocess];
   
   _lc = [CPFactory TRIntArray: _engine range: Columns];
   _lr = [CPFactory TRIntArray: _engine range: Rows];
   for(ORInt i = _lowc; i <= _upc; i++)
      [_lc set: 0 at: i];
   for(ORInt i = _lowr; i <= _upr; i++)
      [_lr set: 0 at: i];
   
   _rowOfColumn = [CPFactory TRIntArray: _engine range: Columns];
   _columnOfRow = [CPFactory TRIntArray: _engine range: Rows];
   for(ORInt i = _lowc; i <= _upc; i++)
      [_rowOfColumn set: MAXINT at: i];
   for(ORInt i = _lowr; i <= _upr; i++)
      [_columnOfRow set: MAXINT at: i];
   
   _columnIsMarked = (ORInt*) malloc(sizeof(ORInt) * (_upc - _lowc + 1));
   _columnIsMarked -= _lowc;
   
   _rowIsMarked = (ORInt*) malloc(sizeof(ORInt) * (_upr - _lowr + 1));
   _rowIsMarked -= _lowr;
   
   _pathRowOfColumn = (ORInt*) malloc(sizeof(ORInt) * (_upc - _lowc + 1));
   _pathRowOfColumn -= _lowc;
   
   _pi = (ORInt*) malloc(sizeof(ORInt) * (_upc - _lowc + 1));
   _pi -= _lowc;
   
   [self reduceCostMatrix];
   [self greedyAssignment];
   //    [self printCostMatrix];
   //    printf("\n");
   //    [self printReducedCostMatrix];
   //    printf("\n");
   //    [self printAssignment];
   
   [self propagate];
   for(ORInt r = _lowr ; r <= _upr; r++) {
      if (![_var[r] bound]) {
         [_var[r] whenChangePropagate: self]; 
         [_var[r] whenLoseValue: self do: ^void(ORInt v) { 
            [_cost set: _bigM at: r : v ];
            if ([_columnOfRow at: r] == v) {
               [_columnOfRow set: MAXINT at: r];
               [_rowOfColumn set: MAXINT at: v];
            }
         }];
      }
   }
   if (![_costVariable bound]) 
      [_costVariable whenChangeMaxPropagate: self];
   return ORSuspend;
}

-(void) preprocess
{   
   for(ORInt i = _lowr; i <= _upr; i++) {
      [_var[i] updateMin: _lowc];
      [_var[i] updateMax: _upc];
   }
   for(ORInt i = _lowr; i <= _upr; i++) 
      for(ORInt v = _lowc; v <= _upc; v++)
         if (![_var[i] member: v])
            [_cost set: _bigM at: i : v];
}

-(void) propagate
{
   for(ORInt r = _lowr; r <= _upr; r++)
      if (!assignedRow(self,r)) 
         [self applyAugmentingPathFrom: r to: [self findAugmentingPathFrom: r]];
   
   int assignmentCost = 0;
   for(ORInt r = _lowr; r <= _upr; r++) 
      assignmentCost += [_cost at: r : [_columnOfRow at: r]];
//   printf("Cost of assignment: %d \n",assignmentCost);
   [_costVariable updateMin: assignmentCost];
   ORInt bound = [_costVariable max] - assignmentCost;
   for(ORInt r = _lowr; r <= _upr; r++)
      for(ORInt c = _lowc; c <= _upc; c++) {
         ORInt cost = [_cost at: r : c];
         if (cost != _bigM && cost - [_lr at: r] - [_lc at: c] > bound) {
//           printf("Prune %d from %d \n",c,r);
            [_var[r] remove: c];
         }
      }
}

-(void) applyAugmentingPathFrom: (ORInt) r to: (ORInt) c
{
   ORInt currentRow;
   ORInt currentCol;
   do {
      currentRow = _pathRowOfColumn[c];
      [_rowOfColumn set: currentRow at: c];
      currentCol = [_columnOfRow at: currentRow];
      [_columnOfRow set: c at: currentRow];
      c = currentCol;
   } while (currentRow != r);
}

-(ORInt) dualStep
{
   ORInt col = _lowc - 1;  // [ldm] this was not initialized.
   ORInt m = MAXINT;
   for(ORInt c = _lowc; c <= _upc; c++)
      if (!_columnIsMarked[c] && _pi[c] < m) {
         m = _pi[c];
         col = c;
      }
   for(ORInt c = _lowc; c <= _upc; c++)
      if (_columnIsMarked[c])
         [_lc set: [_lc at: c] - m at: c];
      else 
         _pi[c] -= m;
   for(ORInt r = _lowr; r <= _upr; r++)
      if (_rowIsMarked[r])
         [_lr set: [_lr at: r] + m at: r];
   return col;
}

-(ORInt) findAugmentingPathFrom: (ORInt) i 
{
   for(ORInt r = _lowr; r <= _upr; r++) 
      _rowIsMarked[r] = false;
   for(ORInt c = _lowc; c <= _upc; c++) 
      _columnIsMarked[c] = false;
   _rowIsMarked[i] = true;
   
   for(ORInt c = _lowc; c <= _upc; c++) {
      _pi[c] = [_cost at: i : c ] - [_lr at: i] - [_lc at: c];
      _pathRowOfColumn[c] = i;
   }
   
   do {
      ORInt col = MAXINT;
      for(ORInt c = _lowc; c <= _upc; c++) 
         if (!_columnIsMarked[c] && _pi[c] == 0) {
            col = c;
            break;
         }
      if (col == MAXINT) 
         col = [self dualStep];
      
      ORInt row;
      if (!assignedColumn(self,col)) 
         return col;
      else {
         row = [_rowOfColumn at: col];
         _rowIsMarked[row] = true;
         _columnIsMarked[col] = true;
      }
      
      for(ORInt c = _lowc; c <= _upc; c++) 
         if (!_columnIsMarked[c]) {
            ORInt m  = [_cost at: row : c] - [_lr at: row] - [_lc at: c];
            if (m < _pi[c]) {
               _pi[c] = m;
               _pathRowOfColumn[c] = row;
            }
         }
      
   } while (true);
   return 0;
}
-(void) printCostMatrix
{
   printf("      ");
   for(ORInt j = _lowc; j <= _upc; j++)
      printf("%2d ",[_lc at: j]);
   printf("\n");
   for(ORInt i = _lowr; i <= _upr; i++) {
      printf("%2d  : ",[_lr at: i]);
      for(ORInt j = _lowc; j <= _upc; j++)
         printf("%2d ",[_cost at: i : j]);
      printf("\n");
   }
}
-(void) printReducedCostMatrix
{
   printf("      ");
   for(ORInt j = _lowc; j <= _upc; j++)
      printf("%2d ",[_lc at: j]);
   printf("\n");
   for(ORInt i = _lowr; i <= _upr; i++) {
      printf("%2d  : ",[_lr at: i]);
      for(ORInt j = _lowc; j <= _upc; j++)
         printf("%2d ",[_cost at: i : j] - [_lc at: j] - [_lr at: i]);
      printf("\n");
   }
}

-(void) printAssignment
{
   printf("     ");
   for(ORInt j = _lowc; j <= _upc; j++) {
      ORInt asg = [_rowOfColumn at: j];
      if (asg != MAXINT)
         printf("%2d ",asg);
      else 
         printf("   ");
   }
   printf("\n");
   for(ORInt i = _lowr; i <= _upr; i++) {
      ORInt asg = [_columnOfRow at: i];
      if (asg != MAXINT)
         printf("%2d : ",asg);
      else 
         printf("   : ");
      for(ORInt j = _lowc; j <= _upc; j++) 
         printf("%2d ",[_cost at: i : j]);
      printf("\n");
   }
   printf("\n");
   for(ORInt j = _lowc; j <= _upc; j++) 
      printf("Row of column %d is %d \n",j,[_rowOfColumn at: j]);
   printf("\n");
   
   for(ORInt i = _lowr; i <= _upr; i++) 
      printf("Column of row %d is %d \n",i,[_columnOfRow at: i]);
   printf("\n");
   int assignmentCost = 0;
   for(ORInt r = _lowr; r <= _upr; r++) 
      assignmentCost += [_cost at: r : [_columnOfRow at: r]];
   printf("Cost of assignment: %d \n",assignmentCost);
   
}

-(void) reduceCostMatrix
{
   for(ORInt j = _lowc; j <= _upc; j++) {
      ORInt min = _bigM;
      ORInt lcj = [_lc at: j];
      for(ORInt i = _lowr; i <= _upr; i++) {
         int v = [_cost at: i : j] - [_lr at: i] - lcj;
         if (v < min)
            min = v;
      }
      [_lc set: lcj + min at: j];
   }
   for(ORInt i = _lowr; i <= _upr; i++) {
      ORInt min = _bigM;
      ORInt lri = [_lr at: i];
      for(ORInt j = _lowc; j <= _upc; j++) {
         int v = [_cost at: i : j] - lri - [_lc at: j];
         if (v < min)
            min = v;
      }
      [_lr set: lri + min at: i];
   }
}

static inline BOOL assignedColumn(CPAssignment* cstr,ORInt j)
{
   return [cstr->_rowOfColumn at: j] != MAXINT;
}
static inline BOOL assignedRow(CPAssignment* cstr,ORInt i)
{
   return [cstr->_columnOfRow at: i] != MAXINT;
}
static inline void assignRow(CPAssignment* cstr,ORInt i,ORInt j)
{
   [cstr->_columnOfRow set: j at: i];
   [cstr->_rowOfColumn set: i at: j];
}
-(void) greedyAssignment
{
   for(ORInt i = _lowr; i <= _upr; i++) 
      for(ORInt j = _lowc; j <= _upc; j++) 
         if (!assignedColumn(self,j)) 
            if ([_cost at: i : j] - [_lc at: j] - [_lr at: i] == 0) {
               assignRow(self,i,j);  
               break;
            }

}
@end

