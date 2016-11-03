/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Andreas Schutt and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <CPUKernel/CPConstraintI.h>
#import <objcp/CPIntVarI.h>
#import <CPScheduler/CPDifference.h>

    // Whether binary priority queue should be used instead of a linear
    // operation for the shortest path calculations
#define DLUSEBINPRIOQUEUE 1

// XXX Check whether 'variable views' have an unique identifier
typedef struct {
    CPIntVar * _var;    // Variable
    ORUInt     _id;     // Unique ID of the variable
    ORInt      _index;  // Internal unique index of the variable
    ORInt      _pi;     // Value of the valid potential function
} DLNode;

typedef struct {
    DLNode * _node;     // Target node
    TRInt  * _weight;   // Edge weight
} DLEdge;

typedef struct {
    TRInt  * _size;     // Size of the array in _edges
    ORInt    _cap;      // Capacity of the array in edges
    DLEdge * _edges;    // Array of edges
} DLEdgeContainer;

typedef enum {
    DLPi = 0,
    DLDelta,
    DLSigma,
    DLLambda
} DLConsLabel;

typedef enum {
    DLConsPure = 0,
    DLConsReif,
    DLConsHalf
} DLConsType;

    // Difference logic constraint of different type
    //  - always true:        x - y <= d
    //  - reified:      b <-> x - y <= d
    //  - half-reified: b  -> x - y <= d
typedef struct {
    CPIntVar   * _b;
    CPIntVar   * _x;
    CPIntVar   * _y;
    ORInt        _d;
    DLConsType   _type;
    TRInt      * _prev;
    TRInt      * _next;
    TRInt      * _label;
} DLCons;

typedef struct {
    TRInt    _size;     // Size of the array '_cons'
    ORInt    _cap;      // Capacity of the array '_cons'
    DLCons * _cons;     // Array of all difference logic constraints
} DLConsContainer;

typedef struct {
    ORInt   _size;
    ORInt   _cap;
    ORInt * _array;
} DLIntContainer;

#define DLARRAYINCR 10


// Global Difference (Logic) Constraint
//
@implementation CPDifference {
    id<CPIntVarArray> _nodes;
    
    DLNode          * _nodes0;  // Nodes in the graph
    DLEdgeContainer * _succ0;   // Outgoing edges
    DLEdgeContainer * _pred0;   // Ingoing edges
    DLConsContainer   _cons0;   // Difference logic constraints

    TRInt     _size;    // Number of nodes/variables
    ORInt     _cap;     // Capacity of the array '_nodes0'
    
    // Maintainance of the constraint states
    //
    TRInt _piFirst;     // Assigned and propagated constraints
    TRInt _piLast;      // Assigned and propagated constraints
    TRInt _deltaFirst;  // Implied constraints from constraints in '_PI'
    TRInt _deltaLast;   // Implied constraints from constraints in '_PI'
    TRInt _sigmaFirst;  // Assigned constraints, but not propagated yet
    TRInt _sigmaLast;   // Assigned constraints, but not propagated yet
    TRInt _lambdaFirst; // Unassigned constraints
    TRInt _lambdaLast;  // Unassigned constraints
    
    // Containers
    DLIntContainer _changeLB;
    DLIntContainer _changeUB;
    
    ORBool _isPosted;   // Whether the propagator is posted
}
-(id) initCPDifference: (id<CPEngine>) engine withInitCapacity:(ORInt)numItems
{
    printf("Creating global difference constraint\n");
    
    // XXX Temporary throwing of execution error so long the
    // implementation is not finished
    @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Implementation is not finished yet!"];
    
    // Avoidance of negative capacity
    numItems = max(numItems, 0);
    self = [super initCPCoreConstraint: engine];

    // TODO Adjusting the priority
    _priority = HIGHEST_PRIO - 2;
    //_idempotent = true;

    _nodes  = NULL;
    _nodes0 = NULL;
    _succ0  = NULL;
    _pred0  = NULL;
    _cons0._cap = 0;
    _cons0._cons = NULL;
    _cap    = numItems;
    
    _changeLB._array = NULL;
    _changeLB._cap   = 0;
    _changeLB._size  = 0;
    _changeUB._array = NULL;
    _changeUB._cap   = 0;
    _changeUB._size  = 0;

    _size = makeTRInt(_trail, 0);
    
    if (_cap > 0) {
        // Allocating memory
        _nodes0 = malloc(_cap * sizeof(DLNode         ));
        _succ0  = malloc(_cap * sizeof(DLEdgeContainer));
        _pred0  = malloc(_cap * sizeof(DLEdgeContainer));
    
        // Check whether memory allocation was successful
        if (_nodes0 == NULL || _succ0 == NULL || _pred0 == NULL) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
        }
    
        // Copying elements to the C struct
        for (ORInt i = 0; i < _cap; i++) {
            // Node initialisations
            _nodes0[i]._var = NULL;
            _nodes0[i]._id  = -1;
            _nodes0[i]._index = i;
            _nodes0[i]._pi  = 0;
        
            // Edge initialisations
            _succ0 [i]._edges = NULL;
            _succ0 [i]._cap   = 0;
            _succ0 [i]._size  = NULL;
            _pred0 [i]._edges = NULL;
            _pred0 [i]._cap   = 0;
            _pred0 [i]._size  = NULL;
        }
    }
    
    _piFirst     = makeTRInt(_trail, -1);
    _piLast      = makeTRInt(_trail, -1);
    _deltaFirst  = makeTRInt(_trail, -1);
    _deltaLast   = makeTRInt(_trail, -1);
    _sigmaFirst  = makeTRInt(_trail, -1);
    _sigmaLast   = makeTRInt(_trail, -1);
    _lambdaFirst = makeTRInt(_trail, -1);
    _lambdaLast  = makeTRInt(_trail, -1);
    
    _isPosted = FALSE;
    return self;
}
-(void) dealloc
{
    if (_nodes0 != NULL) free(_nodes0);
    if (_succ0 != NULL) {
        for (ORInt i = 0; i < _size._val; i++) {
            if (_succ0[i]._size  != NULL) free(_succ0[i]._size );
            if (_succ0[i]._edges != NULL) {
                assert(_succ0[i]._edges != NULL);
                for (ORInt j = 0; j < _succ0[i]._cap; j++) {
                    if (_succ0[i]._edges[j]._weight != NULL)
                        free(_succ0[i]._edges[j]._weight);
                }
                free(_succ0[i]._edges);
            }
        }
        free(_succ0);
    }
    if (_pred0 != NULL) {
        for (ORInt i = 0; i < _size._val; i++) {
            if (_pred0[i]._size  != NULL) free(_pred0[i]._size );
            if (_pred0[i]._edges != NULL) {
                assert(_pred0[i]._edges != NULL);
                for (ORInt j = 0; j < _pred0[i]._cap; j++) {
                    if (_pred0[i]._edges[j]._weight != NULL)
                        free(_pred0[i]._edges[j]._weight);
                }
                free(_pred0[i]._edges);
            }
        }
        free(_pred0);
    }
    if (_cons0._cons != NULL) {
        for (ORInt i = 0; i < _cons0._cap; i++) {
            if (_cons0._cons[i]._label != NULL) free(_cons0._cons[i]._label);
            if (_cons0._cons[i]._next  != NULL) free(_cons0._cons[i]._next );
            if (_cons0._cons[i]._prev  != NULL) free(_cons0._cons[i]._prev );
        }
        free(_cons0._cons);
    }
    if (_changeLB._array != NULL) free(_changeLB._array);
    if (_changeUB._array != NULL) free(_changeUB._array);
    
    [super dealloc];
}
-(void) post
{
//    printf("I am posting a CPDifference Constraint\n");
    _isPosted = TRUE;
    
    // XXX Initial propagation????
}
-(void) propagate
{
    doPropagation(self);
}
-(NSSet*) allVars
{
    NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:_size._val];
    for (ORInt i = 0; i < _size._val; i++) {
        [rv addObject: _nodes0[i]._var];
    }
    [rv autorelease];
    return rv;
}
-(ORUInt) nbUVars
{
    ORInt count = 0;
    for (ORInt i = 0; i < _size._val; i++) {
        if (!_nodes0[i]._var.bound) count++;
    }
    ORInt index = _lambdaFirst._val;
    while (index >= 0) {
        count++;
        index = _cons0._cons[index]._next->_val;
    }
    return count;
}
-(NSString*) description
{
    return [NSString stringWithFormat:@"CPDifference"];
}

-(void) addDifference:(id<CPIntVar>)x minus:(id<CPIntVar>)y leq:(ORInt)d
{
    // Retrieving the nodes that represent x and y
    const ORInt indexX = getNodeIndex(self, (CPIntVar *)x);
    const ORInt indexY = getNodeIndex(self, (CPIntVar *)y);
    
    const ORInt indexEdge = getEdge(self, indexX, indexY);
    
    printf("Add constraint (%d): %d (%u) - %d (%u) <= %d\n", indexEdge, indexX,[x getId],indexY, [y getId], d);
    
    if (!(indexEdge >= 0 && _succ0[indexX]._edges[indexEdge]._weight->_val <= d)) {
        // TODO Check whether this difference constraint is implied
        // Perform consistency check and add an edge to the graph
        doCottonMaler(self, indexX, indexY, d);
        assert(^ORBool(){
            ORInt rdC = _nodes0[indexX]._pi + d - _nodes0[indexY]._pi;
            return (rdC >= 0);
        }());
        // Adding constraint to the database
        addConstraint(self, NULL, (CPIntVar *)x, (CPIntVar *)y, d, DLConsPure, DLSigma);
    }
}

-(void) addReifyDifference:(id<CPIntVar>)b when:(id<CPIntVar>)x minus:(id<CPIntVar>)y leq:(ORInt)d
{
    if (_isPosted == FALSE) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Adding before posting!"];
    }
    
    // TODO Check whether the constraints x - y <= d or y - x <= -d - 1 are implied
    // Check whether b is grounded
    if ([b bound]) {
        const ORInt indexX = getNodeIndex(self, (CPIntVar *)x);
        const ORInt indexY = getNodeIndex(self, (CPIntVar *)y);
        if (b.value == 0) {
            // Add edge y - x <= -d - 1
            const ORInt indexEdge = getEdge(self, indexY, indexX);
            if (!(indexEdge >= 0 && _succ0[indexY]._edges[indexEdge]._weight->_val <= -d - 1)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexY, indexX, -d - 1);
            }
        }
        else {
            // Add edge x - y <= d
            const ORInt indexEdge = getEdge(self, indexX, indexY);
            if (!(indexEdge >= 0 && _succ0[indexX]._edges[indexEdge]._weight->_val <= d)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexX, indexY, d);
            }
        }
        addConstraint(self, (CPIntVar *)b, (CPIntVar *)x, (CPIntVar *)y, d, DLConsReif, DLSigma);
    }
    else {
        // Adding constraint to the database
        const ORInt k = addConstraint(self, (CPIntVar *)b, (CPIntVar *)x, (CPIntVar *)y, d, DLConsReif, DLLambda);
        // Subscription of b with special propagator
        [b whenBindDo:^{[self bindReifDiff:k];} onBehalf:self];
    }
}

-(void) addImplyDifference:(id<CPIntVar>)b when:(id<CPIntVar>)x minus:(id<CPIntVar>)y leq:(ORInt)d
{
    if (_isPosted == FALSE) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Adding before posting!"];
    }
    
    // TODO Check whether the constraints x - y <= d or y - x <= -d - 1 are implied
    // Check whether b is grounded
    if ([b bound]) {
        if (b.value == 1) {
            // Add edge x - y <= d
            const ORInt indexX = getNodeIndex(self, (CPIntVar *)x);
            const ORInt indexY = getNodeIndex(self, (CPIntVar *)y);
            const ORInt indexEdge = getEdge(self, indexX, indexY);
            if (!(indexEdge >= 0 && _succ0[indexX]._edges[indexEdge]._weight->_val <= d)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexX, indexY, d);
            }
        }
        addConstraint(self, (CPIntVar *)b, (CPIntVar *)x, (CPIntVar *)y, d, DLConsHalf, DLSigma);
    }
    else {
        // Adding constraint to the database
        const ORInt k = addConstraint(self, (CPIntVar *)b, (CPIntVar *)x, (CPIntVar *)y, d, DLConsHalf, DLLambda);
        // Subscription of b with special propagator
        [b whenBindDo:^{[self bindImplyDiff:k];} onBehalf:self];
    }
}

-(void) queueChangeLB:(const ORInt) k
{
    // Add 'k' to queue
    if (!inContainer(k, &_changeLB)) addToContainer(k, &_changeLB);
}
-(void) queueChangeUB:(const ORInt) k
{
    // Add 'k' to queue
    if (!inContainer(k, &_changeUB)) addToContainer(k, &_changeUB);
}

-(void) bindReifDiff:(const ORInt) k
{
    assert(0 <= k && k < _cons0._size._val);
    // Run consistency check and add edge
    DLCons cons = _cons0._cons[k];
    if (cons._label->_val == DLLambda) {
        const ORInt indexX = getNodeIndex(self, cons._x);
        const ORInt indexY = getNodeIndex(self, cons._y);
        if (cons._b.value == 1) {
            // TODO Checking the status of the constraint
            // Add edge x - y <= d
            const ORInt indexEdge = getEdge(self, indexX, indexY);
            if (!(indexEdge >= 0 && _succ0[indexX]._edges[indexEdge]._weight->_val <= cons._d)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexX, indexY, cons._d);
            }
        }
        else {
            assert(cons._b.value == 0);
            // TODO Checking the status of the constraint
            // Add edge x - y <= d
            const ORInt indexEdge = getEdge(self, indexY, indexX);
            if (!(indexEdge >= 0 && _succ0[indexY]._edges[indexEdge]._weight->_val <= -cons._d - 1)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexY, indexX, -cons._d - 1);
            }
        }
        labelSigmaLambdaConsAsDelta(self, k);
    }
}
-(void) bindImplyDiff:(const ORInt) k
{
    assert(0 <= k && k < _cons0._size._val);
    DLCons cons = _cons0._cons[k];
    if (cons._label->_val == DLLambda) {
        if (cons._b.value == 1) {
            // TODO Checking the status of the constraint
            // Add edge x - y <= d
            const ORInt indexX = getNodeIndex(self, cons._x);
            const ORInt indexY = getNodeIndex(self, cons._y);
            const ORInt indexEdge = getEdge(self, indexX, indexY);
            if (!(indexEdge >= 0 && _succ0[indexX]._edges[indexEdge]._weight->_val <= cons._d)) {
                // Perform consistency check and add an edge to the graph
                doCottonMaler(self, indexX, indexY, cons._d);
            }
            labelSigmaLambdaConsAsDelta(self, k);
        }
        else {
            // XXX Maybe, an own label for half-reified constraints that are not implied
            labelSigmaLambdaConsAsDelta(self, k);
        }
    }
}

/*******************************************************************************
 Container Operations
 ******************************************************************************/

static void resizeIntContainer(DLIntContainer * cont)
{
    const ORInt newCap = cont->_cap + DLARRAYINCR;
    ORInt * newArray = NULL;
    assert(newCap > cont->_cap);
    
    if (cont->_cap == 0) {
        assert(cont->_array == NULL);
        newArray = malloc(newCap * sizeof(ORInt));
    }
    else {
        newArray = realloc(cont->_array, newCap * sizeof(ORInt));
    }
    if (newArray == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
    }
    
    cont->_array = newArray;
    cont->_cap   = newCap;
}

static bool inContainer(const ORInt k, const DLIntContainer * cont)
{
    // XXX Check can be reduced to O(1) by marking the node
    for (ORInt i = 0; i < cont->_size; i++) {
        if (cont->_array[i] == k) return true;
    }
    return false;
}

static void addToContainer(const ORInt k, DLIntContainer * cont)
{
    if (cont->_size >= cont->_cap) {
        resizeIntContainer(cont);
    }
    cont->_array[(cont->_size)++] = k;
}

static void resetIntContainers(CPDifference * diff)
{
    diff->_changeLB._size = 0;
    diff->_changeUB._size = 0;
}

/*******************************************************************************
 Constraint operations
 ******************************************************************************/

static void resizeConsContainer(CPDifference * diff)
{
    printf("ResizeConsContainer\n");
    DLCons * newCons = NULL;
    ORInt newCap = diff->_cons0._cap + DLARRAYINCR;
    assert(newCap > diff->_cons0._cap);
    if (diff->_cons0._cap == 0) {
        newCons = malloc(newCap * sizeof(DLCons));
        diff->_cons0._size = makeTRInt(diff->_trail, 0);
    }
    else {
        newCons = realloc(diff->_cons0._cons, newCap * sizeof(DLCons));
    }
    
    if (newCons == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
    }
    
    // Initialisation
    for (ORInt i = diff->_cons0._cap; i < newCap; i++) {
        newCons[i]._b     = NULL;
        newCons[i]._x     = NULL;
        newCons[i]._y     = NULL;
        newCons[i]._d     = 0;
        newCons[i]._prev  = NULL;
        newCons[i]._next  = NULL;
        newCons[i]._type  = DLConsPure;
        newCons[i]._label = NULL;
    }
    
    // Updates
    diff->_cons0._cons = newCons;
    diff->_cons0._cap  = newCap;
}

static ORInt addConstraint(CPDifference * diff, CPIntVar * b, CPIntVar * x, CPIntVar * y, ORInt d, DLConsType t, DLConsLabel l)
{
    const ORInt index = diff->_cons0._size._val;
    
    if (index >= diff->_cons0._cap) {
        resizeConsContainer(diff);
    }
    
    assert(index < diff->_cons0._cap);
    
    DLCons * cons = diff->_cons0._cons;
    cons[index]._b    = b;
    cons[index]._x    = x;
    cons[index]._y    = y;
    cons[index]._d    = d;
    cons[index]._type = t;
    
    if (cons[index]._prev == NULL) {
        assert(cons[index]._next == NULL && cons[index]._label == NULL);
        cons[index]._prev  = malloc(sizeof(TRInt));
        cons[index]._next  = malloc(sizeof(TRInt));
        cons[index]._label = malloc(sizeof(TRInt));
        if (cons[index]._prev == NULL || cons[index]._next == NULL || cons[index]._label == NULL) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
        }
        *(cons[index]._prev ) = makeTRInt(diff->_trail, -1);
        *(cons[index]._next ) = makeTRInt(diff->_trail, -1);
        *(cons[index]._label) = makeTRInt(diff->_trail,  l);
    }
    
    assert(cons[index]._prev  != NULL);
    assert(cons[index]._next  != NULL);
    assert(cons[index]._label != NULL);
    
    // Adding constraint to the corresponding list
    switch (l) {
        case DLPi:
            if (diff->_piLast._val == -1) {
                assignTRInt(&(diff->_piFirst), index, diff->_trail);
            }
            else {
                const ORInt prev = diff->_piLast._val;
                assignTRInt(cons[index]._prev, prev,  diff->_trail);
                assignTRInt(cons[prev ]._next, index, diff->_trail);
            }
            assignTRInt(&(diff->_piLast), index, diff->_trail);
            break;
        case DLDelta:
            if (diff->_deltaLast._val == -1) {
                assignTRInt(&(diff->_deltaFirst), index, diff->_trail);
            }
            else {
                const ORInt prev = diff->_deltaLast._val;
                assignTRInt(cons[index]._prev, prev,  diff->_trail);
                assignTRInt(cons[prev ]._next, index, diff->_trail);
            }
            assignTRInt(&(diff->_deltaLast), index, diff->_trail);
            break;
        case DLSigma:
            if (diff->_sigmaLast._val == -1) {
                assignTRInt(&(diff->_sigmaFirst), index, diff->_trail);
            }
            else {
                const ORInt prev = diff->_sigmaLast._val;
                assignTRInt(cons[index]._prev, prev,  diff->_trail);
                assignTRInt(cons[prev ]._next, index, diff->_trail);
            }
            assignTRInt(&(diff->_sigmaLast), index, diff->_trail);
            break;
        case DLLambda:
            if (diff->_lambdaLast._val == -1) {
                assignTRInt(&(diff->_lambdaFirst), index, diff->_trail);
            }
            else {
                const ORInt prev = diff->_lambdaLast._val;
                assignTRInt(cons[index]._prev, prev,  diff->_trail);
                assignTRInt(cons[prev ]._next, index, diff->_trail);
            }
            assignTRInt(&(diff->_lambdaLast), index, diff->_trail);
            break;
    }
    // Updating the label
    if (cons[index]._label->_val != l) {
        assignTRInt(cons[index]._label, l, diff->_trail);
    }

    // Updating the number of constraints in 'diff->_cons0._cons'
    assignTRInt(&(diff->_cons0._size), index + 1, diff->_trail);
    
    return index;
}

static void addDifferenceConstraint(CPDifference * diff, CPIntVar * b, CPIntVar * x, CPIntVar * y, const ORInt d, DLConsType t, DLConsLabel l)
{
    // Retrieving the nodes that represent x and y
    const ORInt indexX = getNodeIndex(diff, x);
    const ORInt indexY = getNodeIndex(diff, y);

    const ORInt indexEdge = getEdge(diff, indexX, indexY);

    if (!(indexEdge >= 0 && diff->_succ0[indexX]._edges[indexEdge]._weight->_val <= d)) {
        // TODO Check whether this difference constraint is implied
        // Perform consistency check and add an edge to the graph
        doCottonMaler(diff, indexX, indexY, d);
        // Adding constraint to the database
        addConstraint(diff, b, x, y, d, t, l);
    }
}

/*******************************************************************************
 Node operations
 ******************************************************************************/

static void resizeNodeContainer(CPDifference * diff)
{
    printf("ResizeNodeContainer\n");
    DLNode          * newNodes = NULL;
    DLEdgeContainer * newSucc  = NULL;
    DLEdgeContainer * newPred  = NULL;
    
    ORInt newCap = diff->_cap + DLARRAYINCR;
    
    if (diff->_cap == 0) {
        newNodes = malloc(newCap * sizeof(DLNode         ));
        newSucc  = malloc(newCap * sizeof(DLEdgeContainer));
        newPred  = malloc(newCap * sizeof(DLEdgeContainer));
    }
    else {
        newNodes = realloc(diff->_nodes0, newCap * sizeof(DLNode         ));
        newSucc  = realloc(diff->_succ0,  newCap * sizeof(DLEdgeContainer));
        newPred  = realloc(diff->_pred0,  newCap * sizeof(DLEdgeContainer));
    }
    
    if (newNodes == NULL || newSucc == NULL || newPred == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
    }
    
    for (ORInt i = diff->_size._val; i < newCap; i++) {
        newSucc[i]._cap   = 0;
        newSucc[i]._edges = NULL;
        newSucc[i]._size  = NULL;
        newPred[i]._cap   = 0;
        newPred[i]._edges = NULL;
        newPred[i]._size  = NULL;
    }
    
    diff->_nodes0 = newNodes;
    diff->_succ0  = newSucc;
    diff->_pred0  = newPred;
    diff->_cap    = newCap;
}

static ORInt addNode(CPDifference * diff, CPIntVar * x)
{
//    printf("Add node %u\n", x.getId);
    const ORInt index = diff->_size._val;
    
    // Check whether the capacity is sufficient
    if (index >= diff->_cap) {
        resizeNodeContainer(diff);
    }

    assert(index < diff->_cap);

    // Initialisations
    diff->_nodes0[index]._var   = x;
    diff->_nodes0[index]._id    = x.getId;
    diff->_nodes0[index]._index = index;
    diff->_nodes0[index]._pi    = 0;
    
    // Subscript variable
    if (!(diff->_nodes0[index]._var.bound)) {
        [diff->_nodes0[index]._var whenChangeMinDo:^{[diff queueChangeLB:index];} onBehalf:diff];
        [diff->_nodes0[index]._var whenChangeMaxDo:^{[diff queueChangeUB:index];} onBehalf:diff];
        [diff->_nodes0[index]._var whenChangeBoundsPropagate: diff];
    }
    
    // Updating the size
    assignTRInt(&(diff->_size), index + 1, diff->_trail);
    
    return index;
}

static ORInt getNodeIndex(CPDifference * diff, CPIntVar * x)
{
    ORInt i = 0;
    const ORUInt idX = x.getId;
    // Search whether the node 'x' exists in the graph
    // TODO Building a Hash table
    for (i = 0; i < diff->_size._val; i++) {
        if (diff->_nodes0[i]._id == idX) {
            return i;
        }
    }
    // Node 'x' does not exist in the graph
    return addNode(diff, x);
}

/*******************************************************************************
 Edge operations
 ******************************************************************************/

    // Increasing the edge container
    //
static void resizeEdgeContainer(CPDifference * diff, DLEdgeContainer * edgeCont)
{
    DLEdge * newEdges = NULL;
    const ORInt cap = edgeCont->_cap;
    ORInt newCap = cap + DLARRAYINCR;

    assert(newCap > cap);
    
    if (cap > 0) {
        assert(edgeCont->_size != NULL);
        newEdges = realloc(edgeCont->_edges, newCap * sizeof(DLEdge));
    }
    else {
        assert(cap == 0);
        assert(edgeCont->_size  == NULL);
        assert(edgeCont->_edges == NULL);
        newEdges = malloc(newCap * sizeof(DLEdge));
        edgeCont->_size = malloc(sizeof(TRInt));
        *(edgeCont->_size) = makeTRInt(diff->_trail, 0);
    }
    
    if (newEdges == NULL || edgeCont->_size == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
    }
    
    for (ORInt i = cap; i < newCap; i++) {
        newEdges[i]._node   = NULL;
        newEdges[i]._weight = NULL;
    }
    
    edgeCont->_edges = newEdges;
    edgeCont->_cap   = newCap;
    
}


    // Adding a backtrackable edge
    //
static void addEdgeAux(CPDifference * diff, DLEdgeContainer * x_cont, const ORInt x, const ORInt y, const ORInt d)
{
    // Check whether there already exists an edge (x,y,d') with d < d'
    const ORInt indexEdge = getEdgeAux(x_cont, y);
    if (indexEdge >= 0) {
        if (x_cont->_edges[indexEdge]._weight->_val > d) {
            assignTRInt(x_cont->_edges[indexEdge]._weight, d, diff->_trail);
        }
        return ;
    }
    
    // Check whether the array of edges must be increased
    if (x_cont->_cap == 0 || x_cont->_cap <= x_cont->_size->_val) {
        resizeEdgeContainer(diff, x_cont);
    }
    
    // Adding the edge
    ORInt index = x_cont->_size->_val;
    x_cont->_edges[index]._node = &diff->_nodes0[y];
    if (x_cont->_edges[index]._weight == NULL) {
        x_cont->_edges[index]._weight = malloc(sizeof(TRInt));
        if (x_cont->_edges[index]._weight == NULL) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory!"];
        }
        *(x_cont->_edges[index]._weight) = makeTRInt(diff->_trail, d);
    }
    else {
        assignTRInt(x_cont->_edges[index]._weight, d, diff->_trail);
    }
    
    // Updating the size
    assignTRInt(x_cont->_size, ++index, diff->_trail);
}

static void addEdge(CPDifference * diff, const ORInt x, const ORInt y, const ORInt d)
{
    //DLEdgeContainer x_cont = diff->_succ0[x];
    // Adding edge to the successor list
    addEdgeAux(diff, &(diff->_succ0[x]), x, y, d);
    // Adding edge to the predecessor list
    addEdgeAux(diff, &(diff->_pred0[y]), y, x, d);
}

static ORInt getEdge(CPDifference * diff, const ORInt x, const ORInt y)
{
    return getEdgeAux(&(diff->_succ0[x]), y);
}

static ORInt getEdgeAux(DLEdgeContainer * x_cont, const ORInt y)
{
    if (x_cont->_cap == 0) return -1;
    const ORInt size = x_cont->_size->_val;
    for (ORInt i = 0; i < size; i++) {
        const ORInt index  = x_cont->_edges[i]._node->_index;
        if (index == y) return i;
    }
    return -1;
}

/*******************************************************************************
 Consistency Checks
 ******************************************************************************/


static void doCottonMaler(CPDifference * diff, const ORInt x, const ORInt y, const ORInt d)
{
    const ORInt size = diff->_size._val;
    // Pre-conditions
    //  - Nodes x and y are already inserted in the graph
    assert(0 <= x && x < size);
    assert(0 <= y && y < size);
    
    ORInt * gamma = NULL;
    ORInt * pi_new = NULL;
    ORInt gamma_y = diff->_nodes0[x]._pi + d - diff->_nodes0[y]._pi;

    if (gamma_y < 0) {
        // Memory allocations
        gamma  = alloca(size * sizeof(ORInt));
        pi_new = alloca(size * sizeof(ORInt));
        
        // Check whether memory allocation was successful
        if (gamma == NULL || pi_new == NULL) {
            @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory"];
        }
        
        // Initialisations
        for (ORInt i = 0; i < size; i++) {
            gamma [i] = 0;
            pi_new[i] = diff->_nodes0[i]._pi;
        }
        gamma[y] = gamma_y;
        
        ORInt s = y;
        // TODO Complexity of the loop can be reduced by using priority queues
        while (gamma[s] < 0 && gamma[x] == 0) {
            
            // Storing new values
            pi_new[s] = diff->_nodes0[s]._pi + gamma[s];
            gamma[s] = 0;
            
            // Iterating over all successors
            if (diff->_succ0[s]._cap > 0) {
                for (ORInt tt = 0; tt < diff->_succ0[s]._size->_val; tt++) {
                    const ORInt t = diff->_succ0[s]._edges[tt]._node->_index;
                    if (pi_new[t] == diff->_nodes0[t]._pi) {
                        const ORInt weight = diff->_succ0[s]._edges[tt]._weight->_val;
                        gamma[t] = min(gamma[t], pi_new[s] + weight - pi_new[t]);
                    }
                }
            }
            
            // Selection of the node with the minimal gamma value
            s = 0;
            for (ORInt i = 1; i < size; i++) {
                if (gamma[i] < gamma[s]) s = i;
            }
        }
        
        // Check consistency
        if (gamma[x] < 0) {
            resetIntContainers(diff);
            failNow();
        }
        
        // Copy pi-function
        for (ORInt i = 0; i < size; i++) {
            diff->_nodes0[i]._pi = pi_new[i];
        }
    }
    
    // Add edge temporarily
    addEdge(diff, x, y, d);
    
    // Check for new bounds
    const ORInt newLB = diff->_nodes0[x]._var.min - d;
    if (newLB > diff->_nodes0[y]._var.min) {
        assert(newLB <= diff->_nodes0[y]._var.max);
        // TODO Check whether the node 'y' will be queued in changeLB
        [diff->_nodes0[y]._var updateMin:newLB];
    }
    const ORInt newUB = diff->_nodes0[y]._var.max + d;
    if (newUB < diff->_nodes0[x]._var.max) {
        assert(newUB >= diff->_nodes0[x]._var.min);
        [diff->_nodes0[x]._var updateMax:newUB];
    }
}

/*******************************************************************************
 Check for Implications
 ******************************************************************************/

static void labelSigmaConsAsPi(CPDifference * diff, const ORInt indexCons)
{
    assert(diff->_cons0._cons[indexCons]._label->_val == DLSigma);
    // Labelled constraint as assigned and implied
    const ORInt prev = diff->_cons0._cons[indexCons]._prev->_val;
    const ORInt next = diff->_cons0._cons[indexCons]._next->_val;

    // Updating the reference of the previous item
    if (prev >= 0) {
        assignTRInt(diff->_cons0._cons[prev]._next, next, diff->_trail);
    }
    else {
        assignTRInt(&(diff->_sigmaFirst), next, diff->_trail);
    }

    // Updating the reference of the next item
    if (next >= 0) {
        assignTRInt(diff->_cons0._cons[next]._prev, prev, diff->_trail);
    }
    else {
        assignTRInt(&(diff->_sigmaLast), prev, diff->_trail);
    }
    
    // Attaching the constraint to the PI list
    const ORInt last = diff->_piLast._val;
    if (last >= 0) {
        assignTRInt(diff->_cons0._cons[last]._next, indexCons, diff->_trail);
    }
    else {
        assignTRInt(&(diff->_piFirst), indexCons, diff->_trail);
        assignTRInt(&(diff->_piLast ), indexCons, diff->_trail);
    }
    assignTRInt(diff->_cons0._cons[indexCons]._prev, last, diff->_trail);
    assignTRInt(diff->_cons0._cons[indexCons]._next,   -1, diff->_trail);
    assignTRInt(diff->_cons0._cons[indexCons]._label, DLPi, diff->_trail);
}

static void labelSigmaLambdaConsAsDelta(CPDifference * diff, const ORInt indexCons)
{
    // Labelled constraint as assigned and implied
    const ORInt prev = diff->_cons0._cons[indexCons]._prev->_val;
    const ORInt next = diff->_cons0._cons[indexCons]._next->_val;
    const DLConsLabel label = diff->_cons0._cons[indexCons]._label->_val;
    
    // Updating the reference of the previous item
    if (prev >= 0) {
        assignTRInt(diff->_cons0._cons[prev]._next, next, diff->_trail);
    }
    else if (label == DLSigma) {
        assignTRInt(&(diff->_sigmaFirst), next, diff->_trail);
    }
    else if (label == DLLambda) {
        assignTRInt(&(diff->_lambdaFirst), next, diff->_trail);
    }
    
    // Updating the reference of the next item
    if (next >= 0) {
        assignTRInt(diff->_cons0._cons[next]._prev, prev, diff->_trail);
    }
    else if (label == DLSigma) {
        assignTRInt(&(diff->_sigmaLast), prev, diff->_trail);
    }
    else if (label == DLLambda) {
        assignTRInt(&(diff->_lambdaLast), prev, diff->_trail);
    }
    
    // Attaching the constraint to the assigned and implied list
    const ORInt last = diff->_deltaLast._val;
    if (last >= 0) {
        assignTRInt(diff->_cons0._cons[last]._next, indexCons, diff->_trail);
    }
    else {
        assignTRInt(&(diff->_deltaFirst), indexCons, diff->_trail);
        assignTRInt(&(diff->_deltaLast ), indexCons, diff->_trail);
    }
    assignTRInt(diff->_cons0._cons[indexCons]._prev, last, diff->_trail);
    assignTRInt(diff->_cons0._cons[indexCons]._next,   -1, diff->_trail);
    assignTRInt(diff->_cons0._cons[indexCons]._label, DLDelta, diff->_trail);
}

static void checkImplication(CPDifference * diff, const ORInt * distX, const ORInt * distY, const ORInt dXY, ORInt indexCons)
{
    while (indexCons >= 0) {
        const ORInt indexU    = getNodeIndex(diff, diff->_cons0._cons[indexCons]._x);
        const ORInt indexV    = getNodeIndex(diff, diff->_cons0._cons[indexCons]._y);
        const ORInt dUV       = diff->_cons0._cons[indexCons]._d;
        const ORInt indexConsNext = diff->_cons0._cons[indexCons]._next->_val;
        
        if (distX[indexU] < MAXINT && distY[indexV] < MAXINT
            && distX[indexU] + distY[indexV] + dXY <= dUV) {
            // Constraint is implied
            // Assign constraint
            if (diff->_cons0._cons[indexCons]._type == DLConsReif) {
                [diff->_cons0._cons[indexCons]._b bind: 1];
            }
            // Labelled constraint as assigned and implied
            labelSigmaLambdaConsAsDelta(diff, indexCons);
        }
        else if (distX[indexV] < MAXINT && distY[indexU] < MAXINT
                 && distX[indexV] + distY[indexU] + dXY <= -dUV -1) {
            // Negated Constraint is implied
            // Assign constraint
            if (diff->_cons0._cons[indexCons]._type == DLConsReif
                || diff->_cons0._cons[indexCons]._type == DLConsHalf) {
                [diff->_cons0._cons[indexCons]._b bind: 0];
            }
            // Labelled constraint as assigned and implied
            labelSigmaLambdaConsAsDelta(diff, indexCons);
        }
        indexCons = indexConsNext;
    }
}

static inline bool isConsImpliedByBounds(const CPIntVar * x, const CPIntVar * y, const ORInt d)
{
    if (x.max - y.min <= d || y.max - x.min < -d) {
        // 'x - y <= d' or 'not(x - y <= d)' is implied
        return true;
    }
    return false;
}

static void checkImplicationByBounds(CPDifference * diff, ORInt indexCons)
{
    while (indexCons >= 0) {
        const CPIntVar   * x = diff->_cons0._cons[indexCons]._x;
        const CPIntVar   * y = diff->_cons0._cons[indexCons]._y;
        const ORInt        d = diff->_cons0._cons[indexCons]._d;
        const DLConsType   t = diff->_cons0._cons[indexCons]._type;
        const ORInt        indexConsNext = diff->_cons0._cons[indexCons]._next->_val;
        
        assert(^ORBool() {
            const DLConsLabel  l = diff->_cons0._cons[indexCons]._label->_val;
            return (l == DLLambda   || l == DLSigma);
        }());
        
        if (x.max - y.min <= d) {
            // 'x - y <= d' is implied
            if (t == DLConsReif) {
                // 'b <->  x - y <= d'
                [diff->_cons0._cons[indexCons]._b bind: 1];
                // XXX Should an edge be added?
                // No.
            }
            // Label constraint to 'DLDelta'
            labelSigmaLambdaConsAsDelta(diff, indexCons);
        }
        else if (y.max - x.min < -d) {
            // 'not(x - y <= d)' is implied
            if (t == DLConsReif || t == DLConsHalf) {
                // 'b <->  x - y <= d' or ' b ->  x - y <= d'
                [diff->_cons0._cons[indexCons]._b bind: 0];
                // XXX Should an edge be added?
            }
            // Label constraint to 'DLDelta'
            labelSigmaLambdaConsAsDelta(diff, indexCons);
        }
        indexCons = indexConsNext;
    }
}

/*******************************************************************************
 Shortest Path Calculations
 ******************************************************************************/


static void doDijkstraWithReducedCost(CPDifference * diff, DLEdgeContainer * cont, ORInt * dist, const ORInt source, const ORBool fwd)
{
    const ORInt size = diff->_size._val;
    ORInt x = source;
    ORBool visited[size];
#if DLUSEBINPRIOQUEUE
    DLBinPrioQueue * queue = newBinPrioQueue(max(size >> 3, 16));
#endif
    
    for (ORInt i = 0; i < size; i++) {
        dist   [i] = MAXINT;
        visited[i] = FALSE;
    }

    // Distance to the source is zero
    dist[source] = 0;
#if DLUSEBINPRIOQUEUE
    insertItemInBinPrioQueue(queue, source, 0);
    
    while (!isEmptyBinPrioQueue(queue)) {
        x = popBinPrioQueue(queue);
#else
    while (x >= 0) {
#endif
        const ORInt pi_x = diff->_nodes0[x]._pi;
        // Mark 'x' as visited
        visited[x] = TRUE;
        
        // Update the distances to the neighbours of 'x'
        if (cont[x]._cap > 0) {
            for (ORInt ii = 0; ii < cont[x]._size->_val; ii++) {
                const ORInt i    = cont[x]._edges[ii]._node->_index;
                const ORInt pi_i = cont[x]._edges[ii]._node->_pi;
                const ORInt d_xi = cont[x]._edges[ii]._weight->_val;
                const ORInt rcD  = (fwd ? pi_x - pi_i : pi_i - pi_x) + d_xi;
                const ORInt dist_i = dist[x] + rcD;
                assert(rcD >= 0);
#if DLUSEBINPRIOQUEUE
                if (dist[i] > dist_i) {
                    if (dist[i] == MAXINT) {
                        insertItemInBinPrioQueue(queue, i, dist_i);
                    }
                    else {
                        decreaseKeyInBinPrioQueue(queue, i, dist_i);
                    }
                    dist[i] = dist_i;
                }
#else
                dist[i] = min(dist[i], dist_i);
#endif
            }
        }

#if DLUSEBINPRIOQUEUE == 0
        // Retrieving the next node
        x = -1;
        ORInt smallest = MAXINT;
        for (ORInt i = 0; i < size; i++) {
            if (dist[i] < smallest && visited[i] == FALSE) {
                x = i;
            }
        }
#endif
    }
}

static void doBoundsByDijkstraWithReducedCostLB(CPDifference * diff, DLEdgeContainer * cont, const ORInt * changed, const ORInt sizeChanged, ORInt * dist)
{
    // Check whether a bounds propagation must be executed
    //
    if (sizeChanged <= 0) return;
    
    const ORInt size = diff->_size._val;
    ORInt  x        = -1;
    ORInt  pi_v0    = MININT;
    ORBool visited[size];
#if DLUSEBINPRIOQUEUE
    DLBinPrioQueue * queue = newBinPrioQueue(min(sizeChanged << 1, size));
#endif
    
    for (ORInt i = 0; i < size; i++) {
        dist   [i] = MAXINT;
        visited[i] = FALSE;
    }
    
    for (ORInt ii = 0; ii < sizeChanged; ii++) {
        const ORInt i = changed[ii];
        const ORInt lb_i = diff->_nodes0[i]._var.min;
        const ORInt pi_i = diff->_nodes0[i]._pi;
        pi_v0 = max(pi_v0, lb_i + pi_i);
        dist[i] = -pi_i - lb_i;
    }

//    printGraph(diff);
    
    for (ORInt ii = 0; ii < sizeChanged; ii++) {
        const ORInt i = changed[ii];
        dist[i] += pi_v0;
        assert(dist[i] >= 0);
#if DLUSEBINPRIOQUEUE
        insertItemInBinPrioQueue(queue, i, dist[i]);
#else
        if (x < 0 || dist[x] > dist[i]) x = i;
#endif
    }

#if DLUSEBINPRIOQUEUE
    while (!isEmptyBinPrioQueue(queue)) {
        x = popBinPrioQueue(queue);
#else
    while (x >= 0) {
#endif
        const ORInt pi_x = diff->_nodes0[x]._pi;
        // Mark 'x' as visited
        visited[x] = TRUE;

        // Calculating the new lower bound
        const ORInt newLB = pi_v0 - pi_x - dist[x];
        assert(newLB >= diff->_nodes0[x]._var.min);
        
        // Updating the new lower bound
        if (newLB > diff->_nodes0[x]._var.min) {
            if (diff->_nodes0[x]._var.max < newLB) {
                resetIntContainers(diff);
                failNow();
            }
            [diff->_nodes0[x]._var updateMin: newLB];
        }
        
        // Propagating the new lower bound to its successors
        if (cont[x]._cap > 0) {
            for (ORInt ii = 0; ii < cont[x]._size->_val; ii++) {
                const DLNode * node_i = cont[x]._edges[ii]._node;
                const ORInt i = node_i->_index;
                const ORInt rcD = pi_x + cont[x]._edges[ii]._weight->_val - node_i->_pi;
                const ORInt dist_i = dist[x] + rcD;
                const ORInt d_v0i = pi_v0 - node_i->_var.min - node_i->_pi;
                if (dist_i < d_v0i) {
                    assert(visited[i] == FALSE);
                    // New lower bound for node 'i'
#if DLUSEBINPRIOQUEUE
                    if (dist[i] > dist_i) {
                        if (dist[i] == MAXINT) {
                            insertItemInBinPrioQueue(queue, i, dist_i);
                        }
                        else {
                            decreaseKeyInBinPrioQueue(queue, i, dist_i);
                        }
                        dist[i] = dist_i;
                    }
#else
                    dist[i] = min(dist[i], dist_i);
#endif
                }
            }
        }
    
#if DLUSEBINPRIOQUEUE == 0
        // Retrieving the next node
        x = -1;
        for (ORInt i = 0; i < size; i++) {
            if (visited[i] == FALSE && ((x < 0 && dist[i] < MAXINT) || dist[i] < dist[x])) {
                x = i;
            }
        }
#endif
    }
}

static void doBoundsByDijkstraWithReducedCostUB(CPDifference * diff, DLEdgeContainer * cont, const ORInt * changed, const ORInt sizeChanged, ORInt * dist)
{
    // Check whether a bounds propagation must be executed
    //
    if (sizeChanged <= 0) return;
    
    const ORInt size = diff->_size._val;
    ORInt  x        = -1;
    ORInt  pi_v0    = MAXINT;
    ORBool visited[size];

#if DLUSEBINPRIOQUEUE
    DLBinPrioQueue * queue = newBinPrioQueue(min(sizeChanged << 1, size));
#endif
    
    for (ORInt i = 0; i < size; i++) {
        dist   [i] = MAXINT;
        visited[i] = FALSE;
    }
    
    for (ORInt ii = 0; ii < sizeChanged; ii++) {
        const ORInt i = changed[ii];
        const ORInt ub_i = diff->_nodes0[i]._var.max;
        const ORInt pi_i = diff->_nodes0[i]._pi;
        pi_v0 = min(pi_v0, ub_i + pi_i);
        dist[i] = pi_i + ub_i;
    }
    
    for (ORInt ii = 0; ii < sizeChanged; ii++) {
        const ORInt i = changed[ii];
        dist[i] -= pi_v0;
        assert(dist[i] >= 0);
#if DLUSEBINPRIOQUEUE
        insertItemInBinPrioQueue(queue, i, dist[i]);
#else
        if (x < 0 || dist[x] > dist[i]) x = i;
#endif
    }
    
//    printGraph(diff);
#if DLUSEBINPRIOQUEUE
    while (!isEmptyBinPrioQueue(queue)) {
        x = popBinPrioQueue(queue);
#else
    while (x >= 0) {
#endif
        const ORInt pi_x = diff->_nodes0[x]._pi;
        // Mark 'x' as visited
        visited[x] = TRUE;
        
        // Calculating the new bound
        const ORInt newUB = dist[x] + pi_v0 - pi_x;
        assert(newUB <= diff->_nodes0[x]._var.max);
        
        // Updating the new bound
        if (newUB < diff->_nodes0[x]._var.max) {
            if (diff->_nodes0[x]._var.min > newUB) {
                resetIntContainers(diff);
                failNow();
            }
            [diff->_nodes0[x]._var updateMax: newUB];
        }
        
        // Propagating the new bound to its successors
        if (cont[x]._cap > 0) {
            for (ORInt ii = 0; ii < cont[x]._size->_val; ii++) {
                const DLNode * node_i = cont[x]._edges[ii]._node;
                const ORInt i = node_i->_index;
                const ORInt rcD = node_i->_pi + cont[x]._edges[ii]._weight->_val - pi_x;
                const ORInt dist_i = dist[x] + rcD;
                const ORInt d_iv0 = node_i->_pi + node_i->_var.max - pi_v0;
                if (dist_i < d_iv0) {
                    assert(visited[i] == FALSE);
                    // New bound for node 'i'
#if DLUSEBINPRIOQUEUE
                    if (dist[i] > dist_i) {
                        if (dist[i] == MAXINT) {
                            insertItemInBinPrioQueue(queue, i, dist_i);
                        }
                        else {
                            decreaseKeyInBinPrioQueue(queue, i, dist_i);
                        }
                        dist[i] = dist_i;
                    }
#else
                    dist[i] = min(dist[i], dist_i);
#endif
                }
            }
        }
        
#if DLUSEBINPRIOQUEUE == 0
        // Retrieving the next node
        x = -1;
        for (ORInt i = 0; i < size; i++) {
            if (visited[i] == FALSE && ((x < 0 && dist[i] < MAXINT) || dist[i] < dist[x])) {
                x = i;
            }
        }
#endif
    }
}

static void testGraph(CPDifference * diff)
{
    for (ORInt i = 0; i < diff->_size._val; i++) {
        const DLNode x = diff->_nodes0[i];
        const DLEdgeContainer succ = diff->_succ0[i];
        if (succ._cap > 0) {
            for (ORInt jj = 0; jj < succ._size->_val; jj++) {
                const ORInt j = succ._edges[jj]._node->_index;
                const ORInt w = succ._edges[jj]._weight->_val;
                const DLNode y = diff->_nodes0[j];
                if (x._var.max > y._var.max + w) {
                    printGraph(diff);
                    printf("%d -(%d)-> %d\n", i, w, j);
                }
                assert(x._var.max <= y._var.max + w);
                assert(x._var.min <= y._var.min + w);
            }
        }
    }
}

static void printGraph(CPDifference * diff)
{
    for (ORInt i = 0; i < diff->_size._val; i++) {
        const DLNode n = diff->_nodes0[i];
        printf("node %d (%u): pi %d; dom [%d,%d]", n._index, n._id, n._pi, n._var.min, n._var.max);
        const DLEdgeContainer succ = diff->_succ0[i];
        if (succ._cap > 0) {
            printf(" succ");
            for (ORInt jj = 0; jj < succ._size->_val; jj++) {
                const ORInt j = succ._edges[jj]._node->_index;
                const ORInt w = succ._edges[jj]._weight->_val;
                printf(": -(%d)-> %d", w, j);
            }
        }
        printf("\n");
    }
}

/*******************************************************************************
 Main Propagation Loop
 ******************************************************************************/


static void doPropagation(CPDifference * diff)
{
    ORInt * distX = NULL;    // Length of the shortest path to node 'x'
    ORInt * distY = NULL;    // Length of the shortest path from node 'y'
    
    if (diff->_sigmaFirst._val < 0 && diff->_changeLB._size < 1 && diff->_changeUB._size < 1) {
        // Nothing to do
        return ;
    }

    distX = alloca(diff->_size._val * sizeof(ORInt));
    distY = alloca(diff->_size._val * sizeof(ORInt));
    
    if (distX == NULL || distY == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory"];
    }
    
    // Propagation of all assigned constraints that have not propagated yet
    //
    while (diff->_sigmaFirst._val >= 0) {
        const ORInt indexCons = diff->_sigmaFirst._val;
        const ORInt indexX    = getNodeIndex(diff, diff->_cons0._cons[indexCons]._x);
        const ORInt indexY    = getNodeIndex(diff, diff->_cons0._cons[indexCons]._y);
        const ORInt dXY       = diff->_cons0._cons[indexCons]._d;
       
        // Calculating shortest path to 'x'
        doDijkstraWithReducedCost(diff, diff->_pred0, distX, indexX, FALSE);
        // Calculating shortest path from 'y'
        doDijkstraWithReducedCost(diff, diff->_succ0, distY, indexY, TRUE);
        // Check implied constraints
        checkImplication(diff, distX, distY, dXY, diff->_cons0._cons[indexCons]._next->_val);
        checkImplication(diff, distX, distY, dXY, diff->_lambdaFirst._val);
        // Relabel constraint
        labelSigmaConsAsPi(diff, indexCons);
    }
    
    // Bounds propagation
    doBoundsByDijkstraWithReducedCostLB(diff, diff->_succ0, diff->_changeLB._array, diff->_changeLB._size, distX);
    doBoundsByDijkstraWithReducedCostUB(diff, diff->_pred0, diff->_changeUB._array, diff->_changeUB._size, distY);
    
    testGraph(diff);
    
    resetIntContainers(diff);
    
    // Check for implied constraints by bounds
    // XXX Should it be before the "graph" implication test?
    checkImplicationByBounds(diff, diff->_sigmaFirst ._val);
    checkImplicationByBounds(diff, diff->_lambdaFirst._val);
    
}

/*******************************************************************************
 Binary Queue
 ******************************************************************************/

#define DLPARENT(i) (i >> 1)
#define DLLEFT(i) (i << 1)
#define DLRIGHT(i) ((i << 1) + 1)

typedef struct {
    ORInt _key;
    ORInt _id;
} DLPair;

typedef struct {
    ORInt    _size;
    ORInt    _cap;
    DLPair * _queue;
} DLBinPrioQueue;

static DLBinPrioQueue * newBinPrioQueue(const ORInt cap)
{
    if (cap < 1) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Must be initialised with a positve capacity"];
    }
    DLBinPrioQueue * queue = NULL;
    queue = malloc(sizeof(DLBinPrioQueue));
    if (queue == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory"];
    }
    // Initialise
    queue->_size  = 0;
    queue->_cap   = 0;
    queue->_queue = NULL;
    
    queue->_queue = malloc((cap + 1) * sizeof(DLPair));
    if (queue->_queue == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory"];
    }
    
    queue->_cap  = cap + 1;
    queue->_size = 1;
    
    return queue;
}

static void deleteBinPrioQueue(DLBinPrioQueue * queue)
{
    if (queue != NULL) {
        if (queue->_queue != NULL) {
            free(queue->_queue);
        }
        free(queue);
    }
}

static void resizeBinPrioQueue(DLBinPrioQueue * queue, const ORInt newCap)
{
    assert(queue != NULL && newCap > 0);
    DLPair * new = NULL;
    
    new = realloc(queue->_queue, newCap * sizeof(DLPair));
    if (new == NULL) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Out of memory"];
    }
    queue->_queue = new;
}

static inline ORBool isEmptyBinPrioQueue(DLBinPrioQueue * queue)
{
    assert(queue != NULL);
    return (queue->_size < 2);
}

static ORInt popBinPrioQueue(DLBinPrioQueue * queue)
{
    if (queue == NULL || queue->_size <= 1) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Invalid pop operation"];
    }
    const ORInt first = queue->_queue[1]._id;
    
    // Removal of first element
    queue->_size--;
    queue->_queue[1]._id  = queue->_queue[queue->_size]._id;
    queue->_queue[1]._key = queue->_queue[queue->_size]._key;
    
    // Heapifying the queue
    heapifyBinPrioQueue(queue, 1);
    
    return first;
}

static void insertItemInBinPrioQueue(DLBinPrioQueue * queue, const ORInt id, const ORInt key)
{
    assert(queue != NULL);
    
    if (queue->_size >= queue->_cap) {
        resizeBinPrioQueue(queue, queue->_cap << 1);
    }
    assert(queue->_queue != NULL);
    queue->_queue[queue->_size]._id  = id;
    queue->_queue[queue->_size]._key = key;
    queue->_size++;
    
    moveItemUpwardInBinPrioQueue(queue, queue->_size - 1);
}

static void decreaseKeyInBinPrioQueue(DLBinPrioQueue * queue, const ORInt id, const ORInt new)
{
    assert(queue != NULL && queue->_size > 1 && queue->_queue != NULL);
    // Search item in O(n)
    ORInt i;
    for (i = 1; i < queue->_size; i++) {
        if (queue->_queue[i]._id == id)
            break;
    }
    if (i >= queue->_size) {
        @throw [[ORExecutionError alloc] initORExecutionError: "CPDifference: Key was not found"];
    }
    if (queue->_queue[i]._key > new) {
        queue->_queue[i]._key = new;
        moveItemUpwardInBinPrioQueue(queue, i);
    }
}

static void heapifyBinPrioQueue(DLBinPrioQueue * queue, ORInt i)
{
    ORInt l, r, extr;
    
    while (true) {
        l = DLLEFT(i);
        r = DLRIGHT(i);
        
        if (l < queue->_size && queue->_queue[l]._key < queue->_queue[i]._key) {
            extr = l;
        }
        else {
            extr = i;
        }
        
        if (r < queue->_size && queue->_queue[r]._key < queue->_queue[extr]._key) {
            extr = r;
        }
        
        if (extr != i) {
            swapItemsInBinPrioQueue(queue, extr, i);
            i = extr;
        }
        else {
            break;
        }
    }
}

inline static void moveItemUpwardInBinPrioQueue(DLBinPrioQueue * queue, ORInt i)
{
    ORInt pI = DLPARENT(i);
    while (i > 1 && queue->_queue[pI]._key > queue->_queue[i]._key) {
        swapItemsInBinPrioQueue(queue, pI, i);
        i  = pI;
        pI = DLPARENT(i);
    }
}

inline static void swapItemsInBinPrioQueue(DLBinPrioQueue * queue, const ORInt i, const ORInt j)
{
    // Swapping the keys
    ORInt tmp = queue->_queue[i]._key;
    queue->_queue[i]._key = queue->_queue[j]._key;
    queue->_queue[j]._key = tmp;
    
    // Swapping the ids
    tmp = queue->_queue[i]._id;
    queue->_queue[i]._id = queue->_queue[j]._id;
    queue->_queue[j]._id = tmp;
}

@end

