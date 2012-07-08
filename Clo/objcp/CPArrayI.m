/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPIntVarI.h"
#import "CPSolverI.h"
#import "CPCreateI.h"
#import "CPBitDom.h"
#import "CPI.h"
#import "CPError.h"
#import "CPTypes.h"
#import "CPDataI.h"
#import "CPArrayI.h"
#import "CPExprI.h"
#import "ORFoundation/ORArrayI.h"

@implementation ORIdArrayI (CP)
-(id<CP>) cp 
{
   return (id<CP>)_tracker;
}
-(id<ORExpr>)index:(id<ORExpr>)idx
{
   return [[CPExprVarSubI alloc] initCPExprVarSubI:(id<CPIntVarArray>)self index:(id<CPExpr>)idx];
   return nil;
}
@end

/*********************************************************************************/
/*             Multi-Dimensional Matrix                                           */
/*********************************************************************************/

@implementation CPIntVarMatrixI

-(CPIntVarMatrixI*) initCPIntVarMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2 domain: (CPRange) domain
{
    self = [super init];
    _cp = cp;  
    _arity = 3;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _range[2] = r2;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _low[2] = r2.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _up[2] = r2.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _size[2] = (r2.up - r2.low + 1);
    _nb = _size[0] * _size[1] * _size[2];
    _flat = malloc(sizeof(id<CPIntVar>) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = [CPFactory intVar: cp domain: domain];   
    return self;
}

-(CPIntVarMatrixI*) initCPIntVarMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1 domain: (CPRange) domain
{
    self = [super init];
    _cp = cp;  
    _arity = 2;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _nb = _size[0] * _size[1];
    _flat = malloc(sizeof(id<CPIntVar>) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = [CPFactory intVar: cp domain: domain];   
    return self;
}

-(void) dealloc 
{
 //   NSLog(@"CPIntVarMatrix dealloc called...\n");
    free(_range);
    free(_low);
    free(_up);
    free(_size);
    free(_i);
    free(_flat);
    [super dealloc];
}
-(CPInt) getIndex
{
    for(CPInt k = 0; k < _arity; k++)
        if (_i[k] < _low[k] || _i[k] > _up[k])
            @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntVarMatrix"];
    int idx = _i[0] - _low[0];
    for(CPInt k = 1; k < _arity; k++)
        idx = idx * _size[k] + (_i[k] - _low[k]);
    return idx;
}
-(CPRange) range: (CPInt) i
{
    if (i < 0 || i >= _arity)
       @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntVarMatrix"]; 
    return _range[i];
}
-(id<CPIntVar>) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2
{
    if (_arity != 3) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    _i[2] = i2;
    return _flat[[self getIndex]];
}
-(id<CPIntVar>) at: (CPInt) i0 : (CPInt) i1
{
    if (_arity != 2) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    return _flat[[self getIndex]];
}

-(NSUInteger)count
{
    return _nb;
}
-(void) descriptionAux: (CPInt) i string: (NSMutableString*) rv
{
    if (i == _arity) {
        [rv appendString:@"<"];
        for(CPInt k = 0; k < _arity; k++) 
            [rv appendFormat:@"%d,",_i[k]];
        [rv appendString:@"> ="];
        [rv appendFormat:@"%@ \n",[_flat[[self getIndex]] description]];
    }
    else {
        for(CPInt k = _low[i]; k <= _up[i]; k++) {
            _i[i] = k;
            [self descriptionAux: i+1 string: rv];
        }
    }
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [self descriptionAux: 0 string: rv];
    return rv;   
}
-(id<CP>) cp
{
    return _cp;
}
-(id<CPSolver>) solver
{
    return [_cp solver];
}
-(CPInt) virtualOffset
{
    return [[_cp solver] virtualOffset:self];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_arity];
    for(CPInt i = 0; i < _arity; i++) {
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].low];
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].up];
    }
    for(CPInt i=0 ; i < _nb ;i++)
        [aCoder encodeObject:_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_arity];
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);    
    _nb = 1;
    for(CPInt i = 0; i < _arity; i++) {
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low[i]];
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up[i]];
        _range[i] = (CPRange){_low[i],_up[i]};
        _size[i] = (_up[i] - _low[i] + 1);
        _nb *= _size[i];
    }
    _flat = malloc(sizeof(CPIntVarI*) * _nb);
    for(CPInt i=0 ; i < _nb ;i++)
        _flat[i] = [aDecoder decodeObject];
    return self;
}

@end


/**********************************************************************************************/
/*                          CPTRIntArray                                                      */
/**********************************************************************************************/


@implementation CPTRIntArrayI 
-(CPTRIntArrayI*) initCPTRIntArray: (id<CP>) cp range: (CPRange) R
{
    self = [super init];
    _cp = cp;
    _trail = [[cp solver] trail];
    _low = R.low;
    _up = R.up;
    _nb = (_up - _low + 1);
    _array = malloc(_nb * sizeof(TRInt));
    _array -= _low;
    for(CPInt i = _low; i <= _up; i++)
        _array[i] = makeTRInt(_trail,0);
    return self;
}
-(void) dealloc
{
    _array += _low;
    free(_array);
    [super dealloc];
}

-(CPInt) at: (CPInt) value
{
    if (value < _low || value > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in CPTRIntArrayElement"];
    return _array[value]._val;
}

-(void) set: (CPInt) value at: (CPInt) idx
{
    if (idx < _low || idx > _up)
        @throw [[ORExecutionError alloc] initORExecutionError: "Index out of range in CPTRIntArrayElement"];
    assignTRInt(_array + idx,value,_trail);
}

-(CPInt) low
{
    return _low;
}
-(CPInt) up
{
    return _up;
}
-(NSUInteger)count
{
    return _nb;
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [rv appendString:@"["];
    for(CPInt i=_low;i<=_up;i++) {
        [rv appendFormat:@"%d:%d",i,_array[i]._val];
        if (i < _up)
            [rv appendString:@","];
    }
    [rv appendString:@"]"];
    return rv;   
}
-(id<CP>) cp
{
    return _cp;
}
-(id<CPSolver>) solver
{
    return [_cp solver];
}
-(CPInt) virtualOffset
{
    return [[_cp solver] virtualOffset:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_up];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
    for(CPInt i=_low;i<=_up;i++) {
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_array[i]._val];
        [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_array[i]._mgc];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
    _array =  malloc(sizeof(TRInt)*_nb);
    _array -= _low;
    for(CPInt i=_low;i<=_up;i++) {
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_array[i]._val];
         [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_array[i]._mgc];
    }
    return self;
}
@end

/*********************************************************************************/
/*             Multi-Dimensional Matrix of Trailable Int                         */
/*********************************************************************************/

@implementation CPTRIntMatrixI

-(CPTRIntMatrixI*) initCPTRIntMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2
{
    self = [super init];
    _cp = cp;  
    _trail = [[cp solver] trail];
    _arity = 3;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _range[2] = r2;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _low[2] = r2.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _up[2] = r2.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _size[2] = (r2.up - r2.low + 1);
    _nb = _size[0] * _size[1] * _size[2];
    _flat = malloc(sizeof(TRInt) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = makeTRInt(_trail,0);   
    return self;
}

-(CPTRIntMatrixI*) initCPTRIntMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1
{
    self = [super init];
    _cp = cp;  
    _trail = [[cp solver] trail];
    _arity = 2;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _nb = _size[0] * _size[1];
    _flat = malloc(sizeof(TRInt) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = makeTRInt(_trail,0);   
    return self;
}

-(void) dealloc 
{
    //   NSLog(@"CPIntVarMatrix dealloc called...\n");
    free(_range);
    free(_low);
    free(_up);
    free(_size);
    free(_i);
    free(_flat);
    [super dealloc];
}
-(CPInt) getIndex
{
    for(CPInt k = 0; k < _arity; k++)
        if (_i[k] < _low[k] || _i[k] > _up[k])
            @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntVarMatrix"];
    int idx = _i[0] - _low[0];
    for(CPInt k = 1; k < _arity; k++)
        idx = idx * _size[k] + (_i[k] - _low[k]);
    return idx;
}
-(CPRange) range: (CPInt) i
{
    if (i < 0 || i >= _arity)
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntVarMatrix"]; 
    return _range[i];
}
-(CPInt) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2
{
    if (_arity != 3) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    _i[2] = i2;
    return _flat[[self getIndex]]._val;
}
-(CPInt) at: (CPInt) i0 : (CPInt) i1
{
    if (_arity != 2) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    return _flat[[self getIndex]]._val;
}

-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2
{
    if (_arity != 3) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    _i[2] = i2;
    assignTRInt(_flat + [self getIndex],value,_trail);
}
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1
{
    if (_arity != 2) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    assignTRInt(_flat + [self getIndex],value,_trail);
}

-(NSUInteger)count
{
    return _nb;
}
-(void) descriptionAux: (CPInt) i string: (NSMutableString*) rv
{
    if (i == _arity) {
        [rv appendString:@"<"];
        for(CPInt k = 0; k < _arity; k++) 
            [rv appendFormat:@"%d,",_i[k]];
        [rv appendString:@"> ="];
        [rv appendFormat:@"%d \n",_flat[[self getIndex]]._val];
    }
    else {
        for(CPInt k = _low[i]; k <= _up[i]; k++) {
            _i[i] = k;
            [self descriptionAux: i+1 string: rv];
        }
    }
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [self descriptionAux: 0 string: rv];
    return rv;   
}
-(id<CP>) cp
{
    return _cp;
}
-(id<CPSolver>) solver
{
    return [_cp solver];
}
-(CPInt) virtualOffset
{
    return [[_cp solver] virtualOffset:self];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_arity];
    for(CPInt i = 0; i < _arity; i++) {
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].low];
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].up];
    }
    for(CPInt i=0 ; i < _nb ;i++) {
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_flat[i]._val];
        [aCoder encodeValueOfObjCType:@encode(CPUInt) at:&_flat[i]._mgc];
    }
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_arity];
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);    
    _nb = 1;
    for(CPInt i = 0; i < _arity; i++) {
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low[i]];
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up[i]];
        _range[i] = (CPRange){_low[i],_up[i]};
        _size[i] = (_up[i] - _low[i] + 1);
        _nb *= _size[i];
    }
    _flat = malloc(sizeof(TRInt) * _nb);
    for(CPInt i=0 ; i < _nb ;i++) {
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_flat[i]._val];
        [aDecoder decodeValueOfObjCType:@encode(CPUInt) at:&_flat[i]._mgc];
    }
    return self;
}

@end

/*********************************************************************************/
/*             Multi-Dimensional Matrix of Int                                   */
/*********************************************************************************/

@implementation CPIntMatrixI

-(CPIntMatrixI*) initCPIntMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1 : (CPRange) r2
{
    self = [super init];
    _cp = cp;  
    _trail = [[cp solver] trail];
    _arity = 3;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _range[2] = r2;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _low[2] = r2.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _up[2] = r2.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _size[2] = (r2.up - r2.low + 1);
    _nb = _size[0] * _size[1] * _size[2];
    _flat = malloc(sizeof(CPInt) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = 0;   
    return self;
}

-(CPIntMatrixI*) initCPIntMatrix:(id<CP>) cp range: (CPRange) r0 : (CPRange) r1
{
    self = [super init];
    _cp = cp;  
    _trail = [[cp solver] trail];
    _arity = 2;
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);
    _range[0] = r0;
    _range[1] = r1;
    _low[0] = r0.low;
    _low[1] = r1.low;
    _up[0] = r0.up;
    _up[1] = r1.up;
    _size[0] = (r0.up - r0.low + 1);
    _size[1] = (r1.up - r1.low + 1);
    _nb = _size[0] * _size[1];
    _flat = malloc(sizeof(CPInt) * _nb);
    for (CPInt i=0 ; i < _nb; i++) 
        _flat[i] = 0;   
    return self;
}

-(void) dealloc 
{
    //   NSLog(@"CPIntVarMatrix dealloc called...\n");
    free(_range);
    free(_low);
    free(_up);
    free(_size);
    free(_i);
    free(_flat);
    [super dealloc];
}
-(CPInt) getIndex
{
    for(CPInt k = 0; k < _arity; k++)
        if (_i[k] < _low[k] || _i[k] > _up[k])
            @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntMatrix"];
    int idx = _i[0] - _low[0];
    for(CPInt k = 1; k < _arity; k++)
        idx = idx * _size[k] + (_i[k] - _low[k]);
    return idx;
}
-(CPRange) range: (CPInt) i
{
    if (i < 0 || i >= _arity)
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong index in CPIntMatrix"]; 
    return _range[i];
}
-(CPInt) at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2
{
    if (_arity != 3) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    _i[2] = i2;
    return _flat[[self getIndex]];
}
-(CPInt) at: (CPInt) i0 : (CPInt) i1
{
    if (_arity != 2) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    return _flat[[self getIndex]];
}

-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1 : (CPInt) i2
{
    if (_arity != 3) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
    _i[2] = i2;
    _flat[[self getIndex]] = value;
}
-(void) set: (CPInt) value at: (CPInt) i0 : (CPInt) i1
{
    if (_arity != 2) 
        @throw [[ORExecutionError alloc] initORExecutionError: "Wrong arity in CPIntVarMatrix"];
    _i[0] = i0;
    _i[1] = i1;
   _flat[[self getIndex]] = value;
}

-(NSUInteger)count
{
    return _nb;
}
-(void) descriptionAux: (CPInt) i string: (NSMutableString*) rv
{
    if (i == _arity) {
        [rv appendString:@"<"];
        for(CPInt k = 0; k < _arity; k++) 
            [rv appendFormat:@"%d,",_i[k]];
        [rv appendString:@"> ="];
        [rv appendFormat:@"%d \n",_flat[[self getIndex]]];
    }
    else {
        for(CPInt k = _low[i]; k <= _up[i]; k++) {
            _i[i] = k;
            [self descriptionAux: i+1 string: rv];
        }
    }
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [self descriptionAux: 0 string: rv];
    return rv;   
}
-(id<CP>) cp
{
    return _cp;
}
-(id<CPSolver>) solver
{
    return [_cp solver];
}
-(CPInt) virtualOffset
{
    return [[_cp solver] virtualOffset:self];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_arity];
    for(CPInt i = 0; i < _arity; i++) {
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].low];
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_range[i].up];
    }
    for(CPInt i=0 ; i < _nb ;i++) 
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_arity];
    _range = malloc(sizeof(CPRange) * _arity);
    _low = malloc(sizeof(CPInt) * _arity);
    _up = malloc(sizeof(CPInt) * _arity);
    _size = malloc(sizeof(CPInt) * _arity);
    _i = malloc(sizeof(CPRange) * _arity);    
    _nb = 1;
    for(CPInt i = 0; i < _arity; i++) {
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low[i]];
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up[i]];
        _range[i] = (CPRange){_low[i],_up[i]};
        _size[i] = (_up[i] - _low[i] + 1);
        _nb *= _size[i];
    }
    _flat = malloc(sizeof(CPInt) * _nb);
    for(CPInt i=0 ; i < _nb ;i++) 
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_flat[i]];
    return self;
}

@end

