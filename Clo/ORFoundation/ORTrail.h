/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORTracker.h>

@protocol ORIntRange;


@protocol ORTrail <NSObject>
-(void) trailInt:(ORInt*) ptr;
-(void) trailUnsigned:(ORUInt*) ptr;
-(void) trailLong:(ORLong*) ptr;
-(void) trailUnsignedLong:(ORULong*) ptr;
-(void) trailId:(id*) ptr;
-(void) trailIdNC:(id*) ptr;
-(void) trailFloat:(float*) ptr;
-(void) trailDouble:(double*) ptr;
-(void) trailLDouble:(long double*)ptr;
-(void) trailClosure:(void(^) (void) ) clo;
-(void) trailRelease:(id)obj;
-(void) trailFree:(void*)ptr;
-(ORUInt) magic;
-(void) incMagic;
@end

@protocol ORMemoryTrail<NSObject,NSCopying>
-(id)track:(id)obj;
-(void)pop;
-(void)backtrack:(ORInt)ofs;
-(id)copy;
-(void)clear;
-(ORInt)trailSize;
-(void)reload:(id<ORMemoryTrail>)t;
@end

typedef struct {
   int    _val;   // TRInt should be a 32-bit wide trailable signed integer
   ORUInt _mgc;
} TRInt;

typedef struct {
   unsigned  _val;   // TRUInt should be a 32-bit wide trailable unsigned integer
   ORUInt _mgc;
} TRUInt;

typedef struct {
   long long _val;   // TRLong should be a 64-bit wide trailable signed integer
   ORUInt    _mgc;
} TRLong;

typedef struct {
   double    _val;
   ORUInt    _mgc;
} TRDouble;

typedef struct {
   long double _val;
   ORUInt      _mgc;
} TRLDouble;

typedef id TRId;
typedef id TRIdNC;

typedef struct {
   int        _nb;
   int        _low;
   TRInt*     _entries;
} TRIntArray;

typedef struct {
   int        _nb;
   int        _low;
   TRDouble*  _entries;
} TRDoubleArray;

typedef struct {
   int        _nb;
   int        _low;
   TRId*      _entries;
} TRIdArray;

typedef struct {
   int    _val;
   ORUInt _mgc;
} FXInt;

@interface ORTrailFunction : NSObject
void trailIntFun(id<ORTrail> t,int* ptr);
void trailDoubleFun(id<ORTrail> t,double* ptr);
void trailUIntFun(id<ORTrail> t,unsigned* ptr);
void trailIdNCFun(id<ORTrail> t,id* ptr);
TRInt makeTRInt(id<ORTrail> trail,int val);
TRUInt makeTRUInt(id<ORTrail> trail,unsigned val);
TRLong makeTRLong(id<ORTrail> trail,long long val);
TRDouble  makeTRDouble(id<ORTrail> trail,double val);
TRLDouble makeTRLDouble(id<ORTrail> trail,long double val);
TRId  makeTRId(id<ORTrail> trail,id val);
TRIdNC  makeTRIdNC(id<ORTrail> trail,id val);
TRIntArray makeTRIntArray(id<ORTrail> trail,int nb,int low);
void  freeTRIntArray(TRIntArray a);
TRDoubleArray makeTRDoubleArray(id<ORTrail> trail,int nb,int low);
void  freeTRDoubleArray(TRDoubleArray a);
TRIdArray makeTRIdArray(id<ORTrail> trail,int nb,int low);
void  freeTRIdArray(TRIdArray a);

void  assignTRInt(TRInt* v,int val,id<ORTrail> trail);
void  assignTRUInt(TRUInt* v,unsigned val,id<ORTrail> trail);
void  assignTRLong(TRLong* v,long long val,id<ORTrail> trail);
void  assignTRDouble(TRDouble* v,double val,id<ORTrail> trail);
void  assignTRLDouble(TRLDouble* v,long double val,id<ORTrail> trail);
void  assignTRId(TRId* v,id val,id<ORTrail> trail);
void  assignTRIdNC(TRIdNC* v,id val,id<ORTrail> trail);
ORInt assignTRIntArray(TRIntArray a,int i,ORInt val,id<ORTrail> trail);
ORInt getTRIntArray(TRIntArray a,int i);
ORDouble assignTRDoubleArray(TRIntArray a,int i,ORDouble val,id<ORTrail> trail);
ORInt getTRDoubleArray(TRDoubleArray a,int i);
void assignTRIdArray(TRIdArray a,int i,id val,id<ORTrail> trail);
id getTRIdArray(TRIdArray a,int i);
void resizeTRIdArray(TRIdArray a,int nb,id<ORTrail> trail);

FXInt makeFXInt(id<ORTrail> trail);
void  incrFXInt(FXInt* v,id<ORTrail> trail);
int   getFXInt(FXInt* v,id<ORTrail> trail);
ORInt trailMagic(id<ORTrail> trail);
@end

// Struct-Based array of trailable Integers
@protocol ORTRIntArray <NSObject>
-(ORInt)  at: (ORInt) value;
-(void)  set: (ORInt) value at: (ORInt) value;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
@end

@protocol ORTRIdArray <NSObject>
-(id)  at: (ORInt) value;
-(void)  set: (id) value at: (ORInt) index;
-(ORInt) low;
-(ORInt) up;
-(NSUInteger) count;
-(NSString*) description;
@end

// Struct-Based matrix of trailable Integers
@protocol ORTRIntMatrix <NSObject>
-(ORInt) at: (ORInt) i1 : (ORInt) i2;
-(ORInt) at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2;
-(void) set: (ORInt) value at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(ORInt) add: (ORInt) delta at: (ORInt) i1 : (ORInt) i2;
-(ORInt) add: (ORInt) delta at: (ORInt) i1 : (ORInt) i2 : (ORInt) i3;
-(id<ORIntRange>) range: (ORInt) i;
-(NSUInteger)count;
-(NSString*) description;
@end
