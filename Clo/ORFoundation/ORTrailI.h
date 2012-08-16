/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORUtilities/ORUtilities.h>
#import "ORData.h"
#import "ORTrail.h"

#define NBSLOT 8192

#define TAGShort        0x1
#define TAGInt          0x2
#define TAGUnsigned     0x3
#define TAGId           0x4
#define TAGFloat        0x5
#define TAGDouble       0x6
#define TAGLong         0x7
#define TAGUnsignedLong 0x8
#define TAGClosure      0x9
#define TAGRelease      0xA
#define TAGFree         0xB
#define TAGIdNC         0xC

@interface ORTrailI : NSObject<NSCoding,ORTrail>
{
   @public
   struct Slot {
      void* ptr;
      union {
         ORInt         intVal;          // 4-bytes
         ORUInt       uintVal;          // 4-bytes
         ORLong       longVal;          // 8-bytes
         ORULong     ulongVal;          // 8-bytes
         float       floatVal;          // 4-bytes
         double     doubleVal;          // 8-bytes
         id             idVal;          // 4-bytes OR 8-bytes depending 32/64 compilation mode
         void*         ptrVal;          // 4 or 8 (pointer)
         void (^cloVal)(void);
      };
      ORInt code;
   };
   struct Segment {
      struct Slot tab[NBSLOT];
      ORInt  top;
   };
   struct Segment** _seg; // array of segments
   ORInt _cSeg;       // current segment
   ORInt _mxSeg;      // maximum # of segments
   ORUInt _magic;     // magic is always 32-bit wide
}
-(ORTrailI*) init;
-(void) dealloc;
-(ORUInt) magic;
-(ORUInt) trailSize;
-(void) resize;
-(void) incMagic;
-(void) trailInt:(ORInt*) ptr;
-(void) trailUnsigned:(ORUInt*) ptr;
-(void) trailLong:(ORLong*) ptr;
-(void) trailUnsignedLong:(ORULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailIdNC:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) trailFree:(void*)ptr;
-(void) backtrack:(ORInt) to;
@end

@interface ORTrailIStack : NSObject {
   ORTrailI*  _trail;
   struct TRNode {
      ORInt   _x;
      ORInt _ofs;
   };
   struct TRNode*  _tab;
   ORInt        _sz;
   ORInt       _mxs;
}
-(ORTrailIStack*) initTrailStack: (ORTrailI*) tr;
-(void) dealloc;
-(void) pushNode:(ORInt) x;
-(void) popNode:(ORInt) x;
-(void) popNode;
-(void) reset;
-(bool) empty;
-(ORInt)size;
@end


@interface ORTrailableIntI : NSObject<ORTrailableInt>
-(ORTrailableIntI*) initORTrailableIntI: (ORTrailI*) trail value:(ORInt) value;
-(ORInt) value;
-(void)  setValue: (ORInt) value;
-(void)  incr;
-(void)  decr;
@end