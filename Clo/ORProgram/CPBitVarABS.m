/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitVarABS.h"
#import "CPEngineI.h"
#import <ORFoundation/ORDataI.h>
#import <objcp/CPStatisticsMonitor.h>
#import <ORFoundation/ORTracer.h>
#import "CPBitVar.h"
#import "CPBitVarI.h"

@interface CPBitAssignmentObj : NSObject<NSCopying> {
   id<CPBitVar>    _x;
   ORUInt        _idx;
   ORBool        _val;
}
-(id)copyWithZone:(NSZone *)zone;
-(id)initCPBitAssignment:(id<CPBitVar>)x idx:(ORUInt) idx val:(ORBool) val;
-(BOOL) isEqual:(id)object;
-(NSUInteger)     hash;
-(id<CPBitVar>) getVar;
-(ORUInt)     getIndex;
-(ORBool)     getValue;
@end

@interface ABSBitVarNogood : NSObject {
   id<CPBitVar>   _var;
   ORUInt         _index;
   ORBool         _val;
}
-(id)initABSBitVarNogood:(id<CPBitVar>)var atIndex:(ORUInt)idx value:(ORBool)val;
-(id<CPBitVar>)variable;
-(ORUInt)index;
-(ORBool)value;
@end

@interface ABSBitVarProbe : NSObject {
   ORFloat*          _tab;
   int                _sz;
   int               _low;
   int                _up;
   NSMutableSet* _inProbe;
}
-(ABSBitVarProbe*)initABSBitVarProbe:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addVar:(id<ORVar>)var;
-(void)scanProbe:(void(^)(ORInt varID,ORFloat activity))block;
@end

@interface ABSBitVarProbeAggregator : NSObject {
   id<ORVarArray>   _vars;
   ORFloat*          _sum;
   ORFloat*        _sumsq;
   int                _sz;
   int               _low;
   int                _up;
   NSMutableSet* _inProbe;
   ORInt        _nbProbes;
   NSMutableDictionary* _values;
}
-(ABSBitVarProbeAggregator*)initABSBitVarProbeAggregator:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addProbe:(ABSBitVarProbe*)p;
-(void)addAssignment:(id<CPBitVar>)x atIndex:(ORUInt)idx toValue:(ORBool)v withActivity:(ORFloat)act;
-(ORInt)nbProbes;
-(ORFloat)avgActivity:(ORInt)x;
-(ORFloat)avgSQActivity:(ORInt)x;
-(NSSet*)variableIDs;
-(void)enumerateForVariable:(ORUInt)x using:(void(^)(ORUInt idx, ORBool value,id activity,BOOL* stop))block;
-(NSString*)description;
@end

@interface ABSBitVariableActivity : NSObject<NSCopying> {
   @package
   id        _theVar;
   ORFloat _activity;
}
-(id)initABSBitVariableActivity:(id)var activity:(ORFloat)initial;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)aging:(ORFloat)rate;
-(ORFloat)activity;
-(void)increase;
@end

@interface ABSBitValueActivity : NSObject<NSCopying> {
   id                    _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSBitActivity:(id)var;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)setActivity:(ORFloat)a atIndex:(ORUInt)idx forValue:(ORBool)v;
-(void)addActivity:(ORFloat)a atIndex:(ORUInt)idx forValue:(ORBool)v;
-(void)addProbeActivity:(ORFloat)a atIndex:(ORUInt)idx  forValue:(ORBool)v;
-(ORFloat)activityForValue:(ORUInt)v atIndex:(ORUInt)idx;
-(void)enumerate:(void(^)(ORUInt idx, ORBool value, id activity, BOOL* stop))block;
-(NSString*)description;
@end

@implementation CPBitAssignmentObj
-(id)initCPBitAssignmentObj:(id<CPBitVar>)x idx:(ORUInt)idx val:(ORBool) val{
   self = [super init];
   _x = x;
   _idx = idx;
   _val = val;
   return self;
}
-(id) copyWithZone:(NSZone *)zone{
   CPBitAssignmentObj* newObject = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:_x idx:_idx val:_val];
   return newObject;
}
-(BOOL) isEqual:(id)object{
   if (![object isKindOfClass:[self class]])
      return NO;
   if (([[object getVar] getId] == [_x getId]) &&
       ([object getIndex] == _idx) &&
       ([object getValue] == _val))
      return YES;
   return NO;
}
-(NSUInteger) hash{
   //Limits size of bitvars
   
   NSUInteger h = [_x getId] << 16;
   h += _idx << 1;
   if (_val) {
      h += 1;
   }
   return h;
}
-(id<CPBitVar>) getVar{
   return _x;
}
-(ORUInt)     getIndex{
   return _idx;
}
-(ORBool)     getValue{
   return _val;
}

@end

@implementation ABSBitVarProbeAggregator
-(ABSBitVarProbeAggregator*)initABSBitVarProbeAggregator:(id<ORVarArray>)vars
{
   self = [super init];
   _vars = vars;
   _low = MAXINT;
   _up  = MININT;
   [vars enumerateWith:^(id<ORBitVar> obj, int idx) {
      ORInt vid = [obj getId];
      _low = min(_low,vid);
      _up  = max(_up,vid);
   }];
   _sz = _up - _low + 1;
   _sum   = malloc(sizeof(ORFloat)*_sz);
   _sumsq = malloc(sizeof(ORFloat)*_sz);
   memset(_sum,0,sizeof(ORFloat)*_sz);
   memset(_sumsq,0,sizeof(ORFloat)*_sz);
   _sum   -= _low;
   _sumsq -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   _nbProbes = 0;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   _sum   += _low;
   _sumsq += _low;
   free(_sum);
   free(_sumsq);
   [_inProbe release];
   [_values release];
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"[AGGREG(%d,%d) = ",_sz,_nbProbes];
   [_inProbe enumerateObjectsUsingBlock:^(NSNumber* key, BOOL *stop) {
      ORInt kv = key.intValue;
      [buf appendFormat:@"<%d , %f , %f>,",kv,_sum[kv],_sumsq[kv]];
   }];
   [buf appendString:@"]"];
   return buf;
}
-(void)addProbe:(ABSBitVarProbe*)p
{
   [p scanProbe:^(ORInt varID, ORFloat activity) {
      NSNumber* key = [[NSNumber alloc] initWithInt:varID];
      [_inProbe addObject:key];
      [key release];
      assert(_low <= varID && varID <= _up);
      _sum[varID]   += activity;
      _sumsq[varID] += activity * activity;
   }];
   _nbProbes++;
}
-(void)addAssignment:(id<CPBitVar>)x atIndex:(ORUInt)idx toValue:(ORBool)v withActivity:(ORFloat)act
{
   //NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:(id<CPBitVar>)x idx:idx val:v];
   ABSBitValueActivity* valueActivity = [_values objectForKey:key];
   if (valueActivity == nil) {
      valueActivity = [[ABSBitValueActivity alloc] initABSBitActivity:x];
      [_values setObject:valueActivity forKey:key];
   }
   [key release];
   [valueActivity addProbeActivity:act atIndex:idx forValue:v];
}

-(void)enumerateForVariable:(ORUInt) x using:(void(^)(ORUInt idx, ORBool val, id activity,BOOL* stop))block
{
   NSNumber* key = [[NSNumber alloc] initWithInt:x];
   [[_values objectForKey:key] enumerate:block];
   [key release];
}

-(ORInt)nbProbes
{
   return _nbProbes;
}
-(ORFloat)avgActivity:(ORInt)x
{
   assert(_low <= x && x <= _up);
   return _sum[x] / _nbProbes;
}
-(ORFloat)avgSQActivity:(ORInt)x
{
   assert(_low <= x && x <= _up);
   return _sumsq[x] / _nbProbes;
}
-(NSSet*)variableIDs
{
   return _inProbe;
}
@end

@implementation ABSBitVarNogood
-(id)initABSBitVarNogood:(id<CPBitVar>)var atIndex:(ORUInt) idx value:(ORBool)val
{
   self = [super init];
   _var = var;
   _index = idx;
   _val = val;
   return self;
}
-(id<CPBitVar>)variable
{
   return _var;
}
-(ORUInt) index
{
   return _index;
}
-(ORBool)value
{
   return _val;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<Nogood var(%d) ** %d>",[_var getId],_val];
   return buf;
}
@end

@implementation ABSBitVarProbe
-(ABSBitVarProbe*)initABSBitVarProbe:(id<ORVarArray>)vars
{
   self = [super init];
   _low = MAXINT;
   _up  = MININT;
   [vars enumerateWith:^(id<ORBitVar> obj, int idx) {
      _low = min(_low,[obj getId]);
      _up  = max(_up,[obj getId]);
   }];
   _sz = _up - _low + 1;
   _tab = malloc(sizeof(ORFloat)*_sz);
   memset(_tab,0,sizeof(ORFloat)*_sz);
   _tab -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   _tab += _low;
   free(_tab);
   [_inProbe release];
   [super dealloc];
}
-(void)addVar:(id<ORVar>)var
{
   ORInt idx = [var getId];
   if (_low <= idx && idx <= _up) {
      NSNumber* vid = [[NSNumber alloc] initWithInt:idx];
      [_inProbe addObject:vid];
      [vid release];
      assert(_low <= idx && idx <= _up);
      _tab[idx] += 1;
   }
}
-(void)scanProbe:(void(^)(ORInt varID,ORFloat activity))block
{
   for(CPBitAssignmentObj* key in _inProbe) {
      assert(_low <= [[key getVar] getId] && [[key getVar]getId] <= _up);
      block([[key getVar]getId],_tab[[[key getVar] getId]]);
   }
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"(%d) [",_sz];
   for(NSNumber* key in _inProbe) {
      [buf appendFormat:@"<%@,%f>,",key,_tab[key.intValue]];
   }
   [buf appendString:@"]"];
   return buf;
}
@end

@implementation ABSBitVariableActivity
-(id)initABSBitVariableActivity:(id)var activity:(ORFloat)initial
{
   self = [super init];
   _theVar = var;
   _activity = initial;
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   return [[ABSBitVariableActivity alloc] initABSBitVariableActivity:_theVar activity:_activity];
}

-(void)dealloc
{
   [super dealloc];
}
-(void)aging:(ORFloat)rate
{
   _activity *= rate;
}
-(ORFloat)activity
{
   return _activity;
}
-(void)increase
{
   _activity += 1;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"var (%d) activity: %f",[_theVar getId],_activity];
   return buf;
}
@end

@implementation ABSBitValueActivity
-(id)initABSBitActivity:(id)var
{
   self = [super init];
   _theVar = var;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   ABSBitValueActivity* copy = [[ABSBitValueActivity alloc] initABSBitActivity:_theVar];
   NSMutableDictionary* cv = [[NSMutableDictionary alloc] initWithCapacity:[_values count]];
   for(NSNumber* key in _values) {
      NSNumber* value = [_values objectForKey:key];
      [cv setObject:[value copy] forKey:key];
   }
   copy->_values = cv;
   return copy;
}

-(void)dealloc
{
   [_values release];
   [super dealloc];
}
-(void)setActivity:(ORFloat)a atIndex:(ORUInt)idx forValue:(ORBool)v
{
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:_theVar idx:idx val:v];

   [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   [key release];
}
-(void)addActivity:(ORFloat)a atIndex:(ORUInt)idx forValue:(ORBool)v
{
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:_theVar idx:idx val:v];
   NSNumber* valAct = [_values objectForKey:key];
   if (valAct==nil) {
      [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   } else {
      ORFloat nv = (([valAct floatValue]  * (ALPHA - 1)) + a)/ ALPHA;
      [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
   }
   [key release];
}
-(void)addProbeActivity:(ORFloat)a atIndex:(ORUInt)idx forValue:(ORBool)v
{
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:_theVar idx:idx val:v];
   NSNumber* valAct = [_values objectForKey:key];
   if (valAct==nil) {
      [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   } else {
      ORFloat nv = [valAct floatValue]   + a;
      [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
   }
   [key release];
}
-(ORFloat)activityForValue:(ORUInt)v atIndex:(ORUInt)idx
{
//   ORUInt keyhash = [_theVar getId];
//   keyhash <<= 16;
//   keyhash += idx;
//   keyhash <<= 1;
//   if (v) {
//      keyhash++;
//   }
//   NSNumber* key = [[NSNumber alloc] initWithLong:keyhash];
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:_theVar idx:idx val:v];
   NSNumber* valAct = [_values objectForKey:key];
   [key release];
   if (valAct == nil)
      return 0.0;
   else
      return [valAct floatValue];
}
-(void)enumerate:(void(^)(ORUInt idx, ORBool val, id activity,BOOL* stop))block
{
   BOOL stop = NO;
   for(CPBitAssignmentObj* key in _values) {
      //extract index and value from key
//      block(key,[_values objectForKey:key],&stop);
      block([key getIndex], [key getValue],[_values objectForKey:key],&stop);
      if (stop)
         return ;
   }
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ValueActivity(%@) = [",_theVar];
   for(NSNumber* value in _values) {
      NSNumber* act = [_values objectForKey:value];
      [buf appendFormat:@"%@ : %@,",value,act];
   }
   [buf appendFormat:@"]"];
   return buf;
}
@end

@implementation CPBitVarABS {
   CPEngineI*               _solver;
   CPStatisticsMonitor*    _monitor;
   ORULong                     _nbv;
   NSMutableDictionary*       _varActivity;
   NSMutableDictionary*       _valActivity;
   NSMutableDictionary*       _varBackup;
   NSMutableDictionary*       _valBackup;
   BOOL                       _freshBackup;
   ORFloat                      _agingRate;
   ORFloat                      _conf;
   id<ORZeroOneStream>          _valPr;
   ABSBitVarProbeAggregator*          _aggregator;
}
-(id)initCPBitVarABS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   _varBackup = _valBackup = nil;
   _agingRate = 0.999;
   _conf      = 0.2;
   return self;
}
- (id)copyWithZone:(NSZone *)zone
{
   CPBitVarABS* cp = [[CPBitVarABS alloc] initCPBitVarABS:_cp restricted:_rvars];
   return cp;
}
-(void)dealloc
{
   [_varActivity release];
   [_valActivity release];
   [_varBackup release];
   [_valBackup release];
   [_aggregator release];
   [super dealloc];
}
-(id<CPCommonProgram>)solver
{
   return _cp;
}
-(ORFloat)varOrdering:(id<CPBitVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:x.getId];
   ABSBitVariableActivity* varAct  = [_varActivity objectForKey:key];
   ORFloat rv = [varAct activity];
   [key release];
   return rv / [x domsize];
}
-(ORFloat)valOrdering:(ORBool)v atIndex:(ORUInt)idx forVar:(id<CPBitVar>)x
{
   
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSBitValueActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v atIndex:idx];
   [key release];
   return - rv;
}
-(void)updateActivities:(id<ORVar>)forVar andVal:(ORBool)val atIndex:(ORUInt)idx
{
   for(NSNumber* key in _varActivity) {
      ABSBitVariableActivity* act = [_varActivity objectForKey:key];
      if (![act->_theVar bound]) {
         [act aging:_agingRate];
      }
   }
   __block int nbActive = 0;
   [_monitor scanActive:^(CPVarInfo *vInfo) {
      NSNumber* key = [[NSNumber alloc] initWithInt:[vInfo getVarID]];
      ABSBitVariableActivity* va = [_varActivity objectForKey:key];
      if (!va) {
         va = [[ABSBitVariableActivity alloc] initABSBitVariableActivity:[vInfo getVar] activity:0];
         [_varActivity setObject:va forKey:key];
         [va release];
      }
      [key release];
      [va increase];
      ++nbActive;
   }];
   //NSNumber* key = [[NSNumber alloc] initWithInt:[forVar getId]];
   CPBitAssignmentObj* key = [[CPBitAssignmentObj alloc] initCPBitAssignmentObj:(id<CPBitVar>)forVar idx:idx val:val];
   ABSBitValueActivity* valAct = [_valActivity objectForKey:key];
   if (!valAct) {
      valAct = [[ABSBitValueActivity alloc] initABSBitActivity:forVar];
      [_valActivity setObject:valAct forKey:key];
      [valAct release];
   }
   [valAct addActivity:nbActive atIndex:idx forValue:val];//Index?
   [key release];
   _freshBackup = NO;
}
-(void)initInternal:(id<ORBitVarArray>)t and:(id<CPBitVarArray>)cvs
{
   _vars = t;
   _cvs  = cvs;
   NSArray* allvars = [[[_cp engine] model] variables];
   id<ORIdArray> o = [ORFactory idArray:[_cp engine] range:[[ORIntRangeI alloc] initORIntRangeI:0 up:[allvars count]]];
   for(int i=0; i< [allvars count];i++)
      [o set:allvars[i] at:i];
   
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:(id<ORVarArray>)o];

//   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:_cvs];
   _nbv = [_cvs count];
   [_solver post:_monitor];
   _varActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   _valActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   
   [self initActivities];
   [self installActivities];
   
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val, ORUInt idx) {
      [self updateActivities:var andVal:val atIndex:idx];
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val, ORUInt idx) {
      [self updateActivities:var andVal:val atIndex:idx];
   }];
   
   //[[_cp engine] clearStatus];
   [[_cp engine] enforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"ABS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"ABS ready...");
}
-(id<CPVarArray>)allBitVars
{
   return (id<CPVarArray>) (_rvars!=nil ? _rvars : _cvs);
}

-(ORUInt)chooseValue:(id<CPBitVar>)x
// Chooses a bit position/not a value for the variable
{
   NSAssert([x isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", x, [[CPBitVarI class] description]);
   return [x randomFreeBit];
}
-(ORBool)moreProbes
{
   const ORFloat prc = _conf;
   int nbProbes = [_aggregator nbProbes];
   BOOL more = NO;
   NSSet* varIDs = [_aggregator variableIDs];
   NSLog(@"AGG: %@",_aggregator);
   for(NSNumber* vid in varIDs) {
      int k = [vid intValue];
      ORFloat muk = [_aggregator avgActivity:k];
      ORFloat muk2 = [_aggregator avgSQActivity:k];
      ORFloat sigmak = sqrt(muk2 - muk*muk);
      ORFloat ratiok = sigmak/sqrt(nbProbes);
      ORFloat lowCI = muk - 1.95 * ratiok;
      ORFloat upCI  = muk + 1.95 * ratiok;
      ORFloat low  = muk * (1.0 - prc);
      ORFloat up   = muk * (1.0 + prc);
      NSLog(@"MOREPROBE: k=%d  %lf [%lf .. %lf] : [%lf .. %lf]  muk = %lf muk2 = %lf ratiok = %lf",k,prc,lowCI,upCI,low,up,muk,muk2,ratiok);
      more |= (low > lowCI || up < upCI );
      if (more)
         break;
   }
   NSLog(@"|PROBEs| = %d more = %s  -- thread: %d",nbProbes,more ? "YES" : "NO",[NSThread threadID]);
   return more;
}
-(void)installActivities
{
   NSSet* varIDs = [_aggregator variableIDs];
   id<CPBitVarArray> vars = (id<CPBitVarArray>)_cvs;
   ORInt nbProbes = [_aggregator nbProbes];
   for(NSNumber* key in varIDs) {
      __block id<CPBitVar> x = nil;
      [vars enumerateWith:^(id<CPBitVar> obj, int idx) {
         if ([obj getId] == [key intValue])
            x= obj;
      }];
      if (x) {
         ORFloat act = [_aggregator avgActivity:[key intValue]];
         ABSBitVariableActivity* xAct = [[ABSBitVariableActivity alloc] initABSBitVariableActivity:x activity:act];
         [_varActivity setObject:xAct forKey:key];
         [xAct release];
         
         ABSBitValueActivity*  valAct = [[ABSBitValueActivity alloc] initABSBitActivity:x];
         [_valActivity setObject:valAct forKey:key];
         [valAct release];
         
         [_aggregator enumerateForVariable:[key intValue] using:^(ORUInt idx, ORBool value, NSNumber* activity, BOOL *stop) {
            [valAct setActivity:[activity floatValue] / nbProbes atIndex:idx forValue:value];
         }];
      }
   }
   _varBackup = [[NSMutableDictionary alloc] initWithCapacity:[_varActivity count]];
   for(NSNumber* key in _varActivity) {
      ABSBitVariableActivity* act = [_varActivity objectForKey:key];
      [_varBackup setObject:[act copy] forKey:key];
   }
   _valBackup = [[NSMutableDictionary alloc] initWithCapacity:[_valActivity count]];
   for(NSNumber* key in _valActivity) {
      ABSBitValueActivity* act = [_valActivity objectForKey:key];
      [_valBackup setObject:[act copy] forKey:key];
   }
   _freshBackup = YES;
}

-(void)initActivities
{
   id<CPBitVarArray> vars = (id<CPBitVarArray>)_cvs;
   id<CPBitVarArray> bvars = [self allBitVars];
   const ORInt nbInRound = 10;
   const ORInt probeDepth = (ORInt) [bvars count];  //TODO: Should the probe depth be based on # of bitvars and their domain size? (treating each bit as a variable)
   float mxp = 0;
   for(ORInt i = [bvars low];i <= [bvars up];i++) {
      //NSAssert([bvars[i] isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", bvars[i], [[CPBitVarI class] description]);
      if ([bvars[i] bound]) continue;
      mxp += [(id)bvars[i] domsize];
//      mxp += log([(id)bvars[i] domsize]);
//      mxp += pow(2,[(id)bvars[i] domsize]);
   }
   const ORInt maxProbes = (int)10 * mxp;
   NSLog(@"#vars:  %d --> maximum # probes: %u  (MXP=%f)",probeDepth,maxProbes,mxp);
   int   cntProbes = 0;
   BOOL  carryOn = YES;
   id<ORTracer> tracer = [_cp tracer];
   _aggregator = [[ABSBitVarProbeAggregator alloc] initABSBitVarProbeAggregator:bvars];
   _valPr = [[ORZeroOneStreamI alloc] init];
   NSMutableSet* killSet = [[NSMutableSet alloc] initWithCapacity:32];
   NSMutableSet* localKill = [[NSMutableSet alloc] initWithCapacity:32];
   __block ORInt* vs = alloca(sizeof(ORInt)*[[vars range] size]);
   __block ORInt nbVS = 0;
   id<ORZeroOneStream> varPr = [[ORZeroOneStreamI alloc] init];
   do {
      for(ORInt c=0;c <= nbInRound;c++) {
         //[_solver clearStatus];
         cntProbes++;
         ABSBitVarProbe* probe = [[ABSBitVarProbe alloc] initABSBitVarProbe:bvars];
         ORInt depth = 0;
         BOOL allBound = NO;
         while (depth <= probeDepth && !allBound) {
            [tracer pushNode];
            nbVS = 0;
            [[bvars range] enumerateWithBlock:^(ORInt i) {
               if (![bvars[i] bound])
                  vs[nbVS++] = i;
            }];
            
            /*
             NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
             [buf  appendString:@"["];
             for(ORInt j=0;j < nbVS; j++)
             [buf appendFormat:@"%d ",vs[j]];
             [buf  appendString:@"]"];
             */
            
            ORInt idx = (ORInt)floor([varPr next] * nbVS);
            ORInt i = vs[idx];
            
            //NSLog(@"chose %i from VS = %@",i, buf);
            
            if (nbVS) { // we found someone
               CPBitVarI* xi = (CPBitVarI*)bvars[i];
               NSAssert([xi isKindOfClass:[CPBitVarI class]], @"%@ should be kind of class %@", xi, [[CPBitVarI class] description]);
               ORUInt idx = [xi randomFreeBit]; //randomize
               ORBool v = arc4random_uniform(2)==0;
               ORStatus s = [_solver enforce: ^{[(id<CPBitVar>)xi bind:idx to:v];}];
               [ORConcurrency pumpEvents];
               __block int nbActive = 0;
               [_monitor scanActive:^(CPVarInfo * vInfo) {
                  nbActive++;
                  [probe addVar:[vInfo getVar]];
               }];
               [_aggregator addAssignment:xi atIndex:idx toValue:v withActivity:nbActive];//atIndex: toValue:
               if (s == ORFailure) {
                  if (depth == 0) {
                     ABSBitVarNogood* nogood = [[ABSBitVarNogood alloc] initABSBitVarNogood:xi atIndex:idx value:v];
                     NSLog(@"Adding SAC %@",nogood);
                     [killSet addObject:nogood];
                     [localKill addObject:nogood];
                     [nogood release];
                  }
                  depth++;
                  break;
               }
            } else allBound = YES;
            depth++;
         }
         if (depth > probeDepth || allBound) {
            if ([_solver objective]==nil) {
               NSLog(@"Found a solution in a CSP while probing!");
               if ([self oneSol])
                  return ;
            } else {
               NSLog(@"ABS found a local optimum = %@",[_solver objective]);
               [[_solver objective] updatePrimalBound];
               //NSLog(@"after updatePrimalBound = %@",[_solver objective]);
            }
         }
         while (depth-- != 0)
            [tracer popNode];
         NSLog(@"THEPROBE: %@",probe);
         [_aggregator addProbe:probe];
         [probe release];
         for(ABSBitVarNogood* b in localKill) {
            
            //TODO:For BitVars we can just bind the bit to  the opposite value
            [_solver enforce: ^{[[b variable] bind:[b index] to:![b value]];}];
            //NSLog(@"Imposing local SAC %@",b);
         }
         [localKill removeAllObjects];
      }
      carryOn = [self moreProbes];
   } while (carryOn && cntProbes < maxProbes);
   
   [_solver atomic:^{
      NSLog(@"Imposing %ld SAC constraints",[killSet count]);
      for(ABSBitVarNogood* b in killSet) {
         [_solver enforce: ^{[[b variable] bind:[b index] to:![b value]];}];
      }
   }];
   
   NSLog(@"Done probing (%d / %u)...",cntProbes,maxProbes);
   [killSet release];
   [varPr release];
   [_valPr release];
}

-(void) restart
{
   NSLog(@"restart(ABS) -- must be stealing now...");
   if (!_freshBackup) {
      [_varActivity removeAllObjects];
      [_valActivity removeAllObjects];
      for(NSNumber* key in _varBackup) {
         ABSBitVariableActivity* act = [_varBackup objectForKey:key];
         [_varActivity setObject:[act copy] forKey:key];
      }
      for(NSNumber* key in _valBackup) {
         ABSBitValueActivity* act = [_valBackup objectForKey:key];
         [_valActivity setObject:[act copy] forKey:key];
      }
   }
}
@end
