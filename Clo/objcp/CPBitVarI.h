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

#import <Foundation/Foundation.h>
#import "CPBitVar.h"
#import "CPIntVarI.h"
#import "CPTypes.h"
#import "CPSolver.h"


@class CPBitArrayDom;
@class CPBitArrayIterator;

typedef struct  {
   TRId         _boundsEvt;
   TRId       _bitFixedEvt;
   TRId            _minEvt;
   TRId            _maxEvt;
} CPBitEventNetwork;


@interface CPBitVarI : NSObject<CPBitVar, CPBitVarNotifier,CPBitVarSubscriber, NSCoding> {
@private
@protected
    CPUInt                         _name;
    CPSolverI*                          _fdm;
    CPBitArrayDom*                      _dom;
    CPBitEventNetwork                   _net;
    CPTriggerMap*                  _triggers;
    id<CPBitVarNotifier>               _recv;
}
-(void) initCPBitVarCore:(id<CPSolver>)fdm low:(unsigned int*)low up:(unsigned int*)up length:(int) len;
//-(CPBitVarI*) initCPBitVarView: (id<CPSolver>) fdm low: (int) low up: (int) up for: (CPBitVarI*) x;
-(void) dealloc;
-(void) setId:(CPUInt)name;
-(NSString*) description;
-(id<CPSolver>) solver;

// need for speeding the code when not using AC5
-(bool) tracksLoseEvt;
-(void) setTracksLoseEvt;

// subscription
-(void) whenBitFixed:(CPCoreConstraint*)c at:(int) p do:(ConstraintCallback) todo;
-(void) whenChangeMin: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeMax: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 
-(void) whenChangeBounds: (CPCoreConstraint*) c at: (int) p do: (ConstraintCallback) todo; 

// notification

//-(void) bindEvt;
-(void) changeMinEvt:(int)dsz;
-(void) changeMaxEvt:(int)dsz;
-(void) bitFixedEvt:(int)dsz;
// access
-(bool) bound;
-(uint64) min;
-(uint64) max;
-(unsigned int*) minArray;
-(unsigned int*) maxArray;
-(unsigned int) getWordLength;
-(void) bounds:(CPBounds*)bnd;
-(unsigned int) domsize;
-(bool) member:(unsigned int*)v;
// update
-(CPStatus)     updateMin: (uint64) newMin;
-(CPStatus)     updateMax: (uint64) newMax;
-(void)         setLow: (unsigned int*) newLow;
-(void)         setUp: (unsigned int*) newUp;
-(TRUInt*)    getLow;
-(TRUInt*)    getUp;
-(CPStatus)     bind:(unsigned int*) val;
-(CPStatus)     bindUInt64:(uint64) val;
//-(CPStatus)     remove:(int) val;
-(CPBitVarI*)    initCPExplicitBitVar: (id<CPSolver>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
-(CPBitVarI*)    initCPExplicitBitVarPat: (id<CPSolver>)fdm withLow: (unsigned int*) low andUp: (unsigned int*) up andLen:(unsigned int) len;
// Class methods
+(CPBitVarI*)   initCPBitVar: (id<CPSolver>)fdm low:(int)low up:(int)up len:(unsigned int)len;
+(CPBitVarI*)   initCPBitVarWithPat:(id<CPSolver>)fdm withLow:(unsigned int *)low andUp:(unsigned int *)up andLen:(unsigned int)len;
+(CPTrigger*)   createTrigger: (ConstraintCallback) todo;
@end


/*****************************************************************************************/
/*                        MultiCast Notifier                                             */
/*****************************************************************************************/

@interface CPBitVarMultiCast : NSObject<CPBitVarNotifier,NSCoding> {
    CPBitVarI**       _tab;
    BOOL    _tracksLoseEvt;
    CPInt          _nb;
    CPInt          _mx;
}
-(id)initVarMC:(int)n;
-(void) dealloc;
-(void) addVar:(CPBitVarI*) v;
-(void) bindEvt;
-(void) bitFixedEvt:(CPUInt) dsz;
@end

