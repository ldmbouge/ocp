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
#import <objcp/CPTypes.h>

#define NBSLOT 8192

@interface CPTrail : NSObject<NSCoding> {
   @package
   struct Slot {
      void* ptr;
      union {
         CPInt         intVal;          // 4-bytes
         CPUInt       uintVal;          // 4-bytes
         CPLong       longVal;          // 8-bytes
         CPULong     ulongVal;          // 8-bytes
         float       floatVal;          // 4-bytes
         double     doubleVal;          // 8-bytes
         id             idVal;          // 4-bytes OR 8-bytes depending 32/64 compilation mode
         void (^cloVal)(void);         
      };
      CPInt code;
   };
   struct Segment {
      struct Slot tab[NBSLOT];
      CPInt  top;
   };
   struct Segment** _seg; // array of segments
   CPInt _cSeg;       // current segment
   CPInt _mxSeg;      // maximum # of segments
   @package
   CPUInt _magic;     // magic is 32/64 depending on compilation mode
}
-(CPTrail*) init;
-(void) dealloc;
-(CPUInt) magic;
-(CPUInt) trailSize;
-(void)resize;
-(void) incMagic;
-(void) trailInt:(CPInt*) ptr;
-(void) trailUnsigned:(CPUInt*) ptr;
-(void) trailLong:(CPLong*) ptr;
-(void) trailUnsignedLong:(CPULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) backtrack:(CPInt) to;
@end

@interface CPTrailStack : NSObject {
   CPTrail*  _trail;
   struct TRNode {
      CPInt   _x;
      CPInt _ofs;
   };
   struct TRNode*  _tab;
   CPInt        _sz;
   CPInt       _mxs;
}
-(CPTrailStack*) initTrailStack: (CPTrail*) tr;
-(void) dealloc;
-(void) pushNode:(CPInt) x;
-(void) popNode:(CPInt) x;
-(void) popNode;
-(void) reset;
-(bool) empty;
-(CPInt)size;
@end

typedef struct {
   int       _val;   // TRInt should be a 32-bit wide trailable signed integer
   CPUInt _mgc;
} TRInt;

typedef struct {
   unsigned  _val;   // TRUInt should be a 32-bit wide trailable unsigned integer
   CPUInt _mgc;
} TRUInt;

typedef struct {
   long long _val;   // TRLong should be a 64-bit wide trailable signed integer
   CPUInt _mgc;
} TRLong;

typedef struct {
   double    _val;
   CPUInt _mgc;
} TRDouble;

typedef struct {
   id        _val;
   CPUInt _mgc;
} TRId;

typedef struct {
    CPTrail* _trail;
    int      _nb;
    int      _low;
    TRInt*   _entries;
} TRIntArray;

typedef struct {
   int       _val;
   CPUInt _mgc;
} FXInt;

TRInt makeTRInt(CPTrail* trail,int val);
void  assignTRInt(TRInt* v,int val,CPTrail* trail);
TRUInt makeTRUInt(CPTrail* trail,unsigned val);
void  assignTRUInt(TRUInt* v,unsigned val,CPTrail* trail);
TRLong makeTRLong(CPTrail* trail,long long val);
void  assignTRLong(TRLong* v,long long val,CPTrail* trail);
TRDouble  makeTRDouble(CPTrail* trail,double val);
void  assignTRDouble(TRDouble* v,double val,CPTrail* trail);
TRId  makeTRId(CPTrail* trail,id val);
void  assignTRId(TRId* v,id val,CPTrail* trail);

TRIntArray makeTRIntArray(CPTrail* trail,int nb,int low);
void       assignTRIntArray(TRIntArray a,int i,int val);
int        getTRIntArray(TRIntArray a,int i);
void       freeTRIntArray(TRIntArray a);

FXInt makeFXInt(CPTrail* trail);
void  incrFXInt(FXInt* v,CPTrail* trail);
int   getFXInt(FXInt* v,CPTrail* trail);
