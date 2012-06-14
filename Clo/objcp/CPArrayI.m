/************************************************************************
 MIT License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 Permission is hereby granted, free of charge, to any person obtaining
 a copy of this software and associated documentation files (the
 "Software"), to deal in the Software without restriction, including
 without limitation the rights to use, copy, modify, merge, publish,
 distribute, sublicense, and/or sell copies of the Software, and to
 permit persons to whom the Software is furnished to do so, subject to
 the following conditions:
 
 The above copyright notice and this permission notice shall be
 included in all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
 EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
 MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
 NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
 LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
 OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
 WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
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

/**********************************************************************************************/
/*                          CPIntArray                                                        */
/**********************************************************************************************/


@implementation CPIntArrayI 
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp size: (CPInt) nb value: (CPInt) value
{
    self = [super init];
    _cp = cp;
    _array = malloc(nb * sizeof(CPIntVarI*));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    for (CPInt i=0 ; i < _nb; i++) 
        _array[i] = value;
    return self;
}
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp size: (CPInt) nb with:(CPInt(^)(CPInt)) clo
{
    self = [super init];
    _cp = cp;
    _array = malloc(nb * sizeof(CPIntVarI*));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    for (CPInt i=0 ; i < _nb; i++) 
        _array[i] = clo(i);
    return self;
}
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) range value: (CPInt) value
{
    self = [super init];
    _cp = cp;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    _array -= _low;
    for (CPInt i=_low ; i <= _up; i++) 
        _array[i] = value;
    return self;
}
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) range with:(CPInt(^)(CPInt)) clo
{
    self = [super init];
    _cp = cp;
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    _array -= _low;
    for (CPInt i=_low ; i <= _up; i++) 
        _array[i] = clo(i);
    return self;
}
-(CPIntArrayI*) initCPIntArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(CPInt(^)(CPInt,CPInt)) clo
{
    self = [super init];
    _cp = cp;    
    _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
    _low = 0;
    _up = _nb-1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    int k = 0;
    for (CPInt i=r1.low ; i <= r1.up; i++) 
        for (CPInt j=r2.low ; j <= r2.up; j++)         
            _array[k++] = clo(i,j);
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
        @throw [[CPExecutionError alloc] initCPExecutionError: "Index out of range in CPIntArrayElement"];
    return _array[value];
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
        [rv appendFormat:@"%d:%d",i,_array[i]];
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
-(CPInt)virtualOffset
{
   return [[_cp solver] virtualOffset:self];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [aCoder encodeObject:_cp];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_low];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_up];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_nb];
    for(CPInt i=_low;i<=_up;i++)
        [aCoder encodeValueOfObjCType:@encode(CPInt) at:_array+i];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
    _array =  malloc(sizeof(CPInt)*_nb);
    _array -= _low;
    for(CPInt i=_low;i<=_up;i++)
        [aDecoder decodeValueOfObjCType:@encode(CPInt) at:_array+i];
    return self;
}
@end

@implementation CPIntVarArrayI 
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp size: (CPInt) nb domain: (CPRange) domain
{
    self = [super init];
    _cp = cp;  
    _array = malloc(nb * sizeof(id<CPIntVar>*));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    for (CPInt i=0 ; i < _nb; i++) 
        _array[i] = [[CPFactory intVar: cp domain: domain] retain];
    return self;
}
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp size: (CPInt) nb with:(CPIntVarI*(^)(CPInt)) clo
{
    self = [super init];
    _cp = cp;    
    _array = malloc(nb * sizeof(CPIntVarI*));
    _low = 0;
    _up = nb-1;
    _nb = nb;
    for (CPInt i=0 ; i < _nb; i++) 
        _array[i] = [clo(i) retain];
    return self;
}
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) range domain: (CPRange) domain
{
    self = [super init];
    _cp = cp;   
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    _array -= _low;
    for (CPInt i=_low ; i <= _up; i++) 
        _array[i] = [[CPFactory intVar: cp domain: domain] retain];
    return self;
}
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) range with:(id<CPIntVar>(^)(CPInt)) clo
{
    self = [super init];
    _cp = cp;   
    _low = range.low;
    _up = range.up;
    _nb = _up - _low + 1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    _array -= _low;
    for (CPInt i=_low ; i <= _up; i++) 
        _array[i] = [clo(i) retain];
    return self;
}
-(CPIntVarArrayI*) initCPIntVarArray: (id<CP>) cp range: (CPRange) r1 range: (CPRange) r2 with:(id<CPIntVar>(^)(CPInt,CPInt)) clo
{
    self = [super init];
    _cp = cp;   
    _nb = (r1.up - r1.low + 1) * (r2.up - r2.low + 1);
    _low = 0;
    _up = _nb-1;
    _array = malloc(_nb * sizeof(CPIntVarI*));
    int k = 0;
    for (CPInt i=r1.low ; i <= r1.up; i++) 
        for (CPInt j=r2.low ; j <= r2.up; j++)         
            _array[k++] = [clo(i,j) retain];
    return self;
}

-(void) dealloc
{
    for (CPInt i=_low ; i <= _up; i++) 
        [_array[i] release];
    _array += _low;
    free(_array);
    [super dealloc];
}
-(id<CPIntVar>*)flat
{
   return _array;
}
-(id<CPIntVar>) at: (CPInt) value
{
    if (value < _low || value > _up)
        @throw [[CPExecutionError alloc] initCPExecutionError: "Index out of range in CPIntArrayElement"];
    return _array[value];
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
        [rv appendFormat:@"%d:",i];
        [rv appendString:[_array[i] description]];
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
    for(CPInt i=_low;i<=_up;i++)
        [aCoder encodeObject:_array[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_low];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_up];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_nb];
    _array =  malloc(sizeof(id<CPIntVar>)*_nb);
    _array -= _low;
    for(CPInt i=_low;i<=_up;i++)
        _array[i] = [[aDecoder decodeObject] retain];
    return self;
}
@end

/*********************************************************************************/
/*             Matrix                                                            */
/*********************************************************************************/

@implementation CPIntVarMatrixI
-(CPIntVarMatrixI*)initCPIntVarMatrix:(id<CP>)cp rows:(CPInt) r cols:(CPInt)c domain:(CPRange)domain
{
    self = [super init];
    _cp = cp;  
    CPInt sz = r * c;
    _flat = malloc(sizeof(id<CPIntVar>) * sz);
    _lowr = 0;
    _upr = r-1;
    _lowc = 0;
    _upc = c-1;
    _nbRows = r;         
    _nbCols = c;
    for (CPInt i=0 ; i < sz; i++) 
        _flat[i] = [[CPFactory intVar: cp domain: domain] retain];   
    return self;
}
-(CPIntVarMatrixI*) initCPIntVarMatrix:(id<CP>)cp rowRange:(CPRange) r colRange:(CPRange)c domain:(CPRange)domain
{
    self = [super init];
    _cp = cp;   
    _lowr = r.low;
    _upr = r.up;
    _lowc = c.low;
    _upc = c.up;
    _nbRows = (_upr - _lowr + 1);
    _nbCols = (_upc - _lowc + 1);
    CPInt sz = _nbRows * _nbCols;
    _flat = malloc(sizeof(CPIntVarI*) * sz);
    for (CPInt i=0 ; i < sz; i++)   
        _flat[i] = [[CPFactory intVar: cp domain: domain] retain];           
    return self;
}
-(void)dealloc 
{
    NSLog(@"CPIntVarMatrix dealloc called...\n");
    CPInt sz = _nbRows * _nbCols;
    for (CPInt i=0 ; i < sz; i++)   
        [_flat[i] release];     
    free(_flat);
    [super dealloc];
}
-(NSMutableArray*)row:(CPInt)r
{
    NSMutableArray* rv = [NSMutableArray arrayWithCapacity:_nbCols+1];
    for(CPInt c =0;c<_nbCols;c++)
        [rv insertObject:_flat[(r - _lowr) * _nbCols + c] atIndex:c];
    return rv;
}

-(id<CPIntVar>) atRow:(CPInt)r col:(CPInt)c
{
    if (r < _lowr || r > _upr || c < _lowc || c > _upc)
        @throw [[CPExecutionError alloc] initCPExecutionError: "Index out of range in CPIntMatrixElement"];      
    CPInt i = (r - _lowr) * _nbCols + (c - _lowc);
    return _flat[i];
}
-(NSUInteger)count
{
    return _nbRows * _nbCols;
}
-(NSString*)description
{
    NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [rv appendString:@"["];
    for(CPInt i = _lowr; i <= _upr; ++i) {
        for (CPInt j = _lowc; j <= _upc; ++j) {
            [rv appendFormat:@"<%d,%d> = %@",i,j,[_flat[(i-_lowr)*_nbCols+(j-_lowc)] description]];
            [rv appendString:@"\n"];         
        }
    }
    [rv appendString:@"]"];
    return rv;   
}
-(CPRange) rowRange
{
    return (CPRange){_lowr,_upr};
}
-(CPRange) columnRange
{
    return (CPRange){_lowc,_upc};
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
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_lowr];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_upr];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_lowc];
    [aCoder encodeValueOfObjCType:@encode(CPInt) at:&_upc];
    CPInt sz = _nbRows * _nbCols;
    for(CPInt i=0 ; i < sz ;i++)
        [aCoder encodeObject:_flat[i]];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super init];
    _cp = [[aDecoder decodeObject] retain];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_lowr];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_upr];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_lowc];
    [aDecoder decodeValueOfObjCType:@encode(CPInt) at:&_upc];
    _nbRows = (_upr - _lowr + 1);
    _nbCols = (_upc - _lowc + 1);
    CPInt sz = _nbRows * _nbCols;
    _flat = malloc(sizeof(CPIntVarI*) * sz);
    for(CPInt i=0 ; i < sz ;i++)
        _flat[i] = [[aDecoder decodeObject] retain];
    return self;
}

@end
