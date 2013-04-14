/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "CPBitVarABS.h"
#import "CPEngineI.h"
#import <objcp/CPStatisticsMonitor.h>
#import <ORFoundation/ORTracer.h>

@interface ABSBitVarNogood : NSObject {
   id<CPBitVar> _var;
   ORInt        _val;
}
-(id)initABSBitVarNogood:(id<CPIntVar>)var value:(ORInt)val;
-(id<CPBitVar>)variable;
-(ORInt)value;
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
-(void)addVar:(id<ORBitVar>)var;
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
-(void)addAssignment:(id<CPBitVar>)x toValue:(ORInt)v withActivity:(ORFloat)act;
-(ORInt)nbProbes;
-(ORFloat)avgActivity:(ORInt)x;
-(ORFloat)avgSQActivity:(ORInt)x;
-(NSSet*)variableIDs;
-(void)enumerateForVariabe:(ORInt)x using:(void(^)(id value,id activity,BOOL* stop))block;
-(NSString*)description;
@end

@interface ABSBitVarActivity : NSObject<NSCopying> {
   @package
   id        _theVar;
   ORFloat _activity;
}
-(id)initABSBitVarActivity:(id)var activity:(ORFloat)initial;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)aging:(ORFloat)rate;
-(ORFloat)activity;
-(void)increase;
@end

@interface ABSBitVarValueActivity : NSObject<NSCopying> {
   id                    _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSBitVarValueActivity:(id)var;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)setActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addProbeActivity:(ORFloat)a forValue:(ORInt)v;
-(ORFloat)activityForValue:(ORInt)v;
-(void)enumerate:(void(^)(id value,id activity,BOOL* stop))block;
-(NSString*)description;
@end

@implementation ABSBitVarProbeAggregator
-(ABSBitVarProbeAggregator*)initABSBitVarProbeAggregator:(id<ORVarArray>)vars
{
   self = [super init];
   _vars = vars;
   _low = MAXINT;
   _up  = MININT;
   [vars enumerateWith:^(id<ORIntVar> obj, int idx) {
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
-(void)addAssignment:(id<CPBitVar>)x toValue:(ORInt)v withActivity:(ORFloat)act
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSBitVarValueActivity* valueActivity = [_values objectForKey:key];
   if (valueActivity == nil) {
      valueActivity = [[ABSBitVarValueActivity alloc] initABSBitVarValueActivity:x];
      [_values setObject:valueActivity forKey:key];
   }
   [key release];
   [valueActivity addProbeActivity:act forValue:v];
}

-(void)enumerateForVariabe:(ORInt)x using:(void(^)(id value,id activity,BOOL* stop))block
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
-(id)initABSBitVarNogood:(id<CPBitVar>)var value:(ORInt)val
{
   self = [super init];
   _var = var;
   _val = val;
   return self;
}
-(id<CPBitVar>)variable
{
   return _var;
}
-(ORInt)value
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
   [vars enumerateWith:^(id<ORIntVar> obj, int idx) {
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
   NSNumber* vid = [[NSNumber alloc] initWithInt:idx];
   [_inProbe addObject:vid];
   [vid release];
   assert(_low <= idx && idx <= _up);
   _tab[idx] += 1;
}
-(void)scanProbe:(void(^)(ORInt varID,ORFloat activity))block
{
   for(NSNumber* key in _inProbe) {
      assert(_low <= key.intValue && key.intValue <= _up);
      block(key.intValue,_tab[key.intValue]);
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

@implementation ABSBitVarActivity
-(id)initABSBitVarActivity:(id)var activity:(ORFloat)initial
{
   self = [super init];
   _theVar = var;
   _activity = initial;
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   return [[ABSBitVarActivity alloc] initABSBitVarActivity:_theVar activity:_activity];
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

@implementation ABSBitVarValueActivity
-(id)initABSBitVarValueActivity:(id)var
{
   self = [super init];
   _theVar = var;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   ABSBitVarValueActivity* copy = [[ABSBitVarValueActivity alloc] initABSBitVarValueActivity:_theVar];
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
-(void)setActivity:(ORFloat)a forValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   [key release];
}
-(void)addActivity:(ORFloat)a forValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   NSNumber* valAct = [_values objectForKey:key];
   if (valAct==nil) {
      [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   } else {
      ORFloat nv = (([valAct floatValue]  * (ALPHA - 1)) + a)/ ALPHA;
      [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
   }
   [key release];
}
-(void)addProbeActivity:(ORFloat)a forValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   NSNumber* valAct = [_values objectForKey:key];
   if (valAct==nil) {
      [_values setObject:[[NSNumber alloc] initWithFloat:a] forKey:key];
   } else {
      ORFloat nv = [valAct floatValue]   + a;
      [_values setObject:[[NSNumber alloc] initWithFloat:nv] forKey:key];
   }
   [key release];
}
-(ORFloat)activityForValue:(ORInt)v
{
   NSNumber* key = [[NSNumber alloc] initWithInt:v];
   NSNumber* valAct = [_values objectForKey:key];
   [key release];
   if (valAct == nil)
      return 0.0;
   else
      return [valAct floatValue];
}
-(void)enumerate:(void(^)(id value,id activity,BOOL* stop))block
{
   BOOL stop = NO;
   for(NSNumber* key in _values) {
      block(key,[_values objectForKey:key],&stop);
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
-(ORFloat)varOrdering:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[[x dereference] getId]];
   ABSBitVarActivity* varAct  = [_varActivity objectForKey:key];
   ORFloat rv = [varAct activity];
   [key release];
   return rv / [x domsize];
}
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[[x dereference] getId]];
   ABSBitVarActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v];
   [key release];
   return - rv;
}
-(void)updateActivities:(id<ORVar>)forVar andVal:(ORInt)val
{
   for(NSNumber* key in _varActivity) {
      ABSBitVarActivity* act = [_varActivity objectForKey:key];
      if (![act->_theVar bound]) {
         [act aging:_agingRate];
      }
   }
   __block int nbActive = 0;
   [_monitor scanActive:^(CPVarInfo *vInfo) {
      NSNumber* key = [[NSNumber alloc] initWithInt:[vInfo getVarID]];
      ABSBitVarActivity* va = [_varActivity objectForKey:key];
      if (!va) {
         va = [[ABSBitVarActivity alloc] initABSBitVarActivity:[vInfo getVar] activity:0];
         [_varActivity setObject:va forKey:key];
         [va release];
      }
      [key release];
      [va increase];
      ++nbActive;
   }];
   NSNumber* key = [[NSNumber alloc] initWithInt:[forVar getId]];
   ABSBitVarValueActivity* valAct = [_valActivity objectForKey:key];
   if (!valAct) {
      valAct = [[ABSBitVarValueActivity alloc] initABSBitVarValueActivity:forVar];
      [_valActivity setObject:valAct forKey:key];
      [valAct release];
   }
   [valAct addActivity:nbActive forValue:val];
   [key release];
   _freshBackup = NO;
}
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:[_cp engine] vars:_vars];
   _nbv = [_vars count];
   [_solver post:_monitor];
   _varActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   _valActivity = [[NSMutableDictionary alloc] initWithCapacity:32];
   
   [self initActivities];
   [self installActivities];
   
   [[[_cp portal] retLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val) {
      [self updateActivities:var andVal:val];
   }];
   [[[_cp portal] failLabel] wheneverNotifiedDo:^void(id<ORVar> var,ORInt val) {
      [self updateActivities:var andVal:val];
   }];
   
   [[_cp engine] clearStatus];
   [[_cp engine] enforceObjective];
   if ([[_cp engine] objective] != NULL)
      NSLog(@"ABS ready... %@",[[_cp engine] objective]);
   else
      NSLog(@"ABS ready...");
}
-(id<ORVarArray>)allBitVars
{
   return (id<ORVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(ORInt)chooseValue:(id<CPBitVar>)x
{
   ORBounds b = [x bounds];
   while (true) {
      double p   = [_valPr next];
      ORInt v    = b.min + floor(p * ((ORFloat)(b.max - b.min + 1)));
      if ([x member:v])
         return v;
   }
}
-(BOOL)moreProbes
{
   const ORFloat prc = _conf;
   int nbProbes = [_aggregator nbProbes];
   BOOL more = NO;
   NSSet* varIDs = [_aggregator variableIDs];
   //NSLog(@"AGG: %@",_aggregator);
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
      //NSLog(@"MOREPROBE: k=%d  %lf [%lf .. %lf] : [%lf .. %lf]  muk = %lf muk2 = %lf ratiok = %lf",k,prc,lowCI,upCI,low,up,muk,muk2,ratiok);
      more |= (low > lowCI || up < upCI );
      if (more)
         break;
   }
   //NSLog(@"|PROBEs| = %d more = %s  -- thread: %d",nbProbes,more ? "YES" : "NO",[NSThread threadID]);
   return more;
}
-(void)installActivities
{
   NSSet* varIDs = [_aggregator variableIDs];
   id<CPIntVarArray> vars = (id<CPIntVarArray>)_vars;//[self allIntVars];
   ORInt nbProbes = [_aggregator nbProbes];
   for(NSNumber* key in varIDs) {
      __block id<CPIntVar> x = nil;
      [vars enumerateWith:^(id<CPIntVar> obj, int idx) {
         if ([obj getId] == key.intValue)
            x= obj;
      }];
      if (x) {
         ORFloat act = [_aggregator avgActivity:[key intValue]];
         ABSBitVarActivity* xAct = [[ABSBitVarActivity alloc] initABSBitVarActivity:x activity:act];
         [_varActivity setObject:xAct forKey:key];
         [xAct release];
         
         ABSBitVarValueActivity*  valAct = [[ABSBitVarValueActivity alloc] initABSBitVarValueActivity:x];
         [_valActivity setObject:valAct forKey:key];
         [valAct release];
         [_aggregator enumerateForVariabe:[key intValue] using:^(NSNumber* value, NSNumber* activity, BOOL *stop) {
            [valAct setActivity:[activity floatValue] / nbProbes forValue:[value intValue]];
         }];
      }
   }
   _varBackup = [[NSMutableDictionary alloc] initWithCapacity:[_varActivity count]];
   for(NSNumber* key in _varActivity) {
      ABSBitVarActivity* act = [_varActivity objectForKey:key];
      [_varBackup setObject:[act copy] forKey:key];
   }
   _valBackup = [[NSMutableDictionary alloc] initWithCapacity:[_valActivity count]];
   for(NSNumber* key in _valActivity) {
      ABSBitVarValueActivity* act = [_valActivity objectForKey:key];
      [_valBackup setObject:[act copy] forKey:key];
   }
   _freshBackup = YES;
}

-(void)initActivities
{
   const ORInt nbInRound = 10;
   const ORInt probeDepth = (ORInt) [_vars count];
   float mxp = 0;
   for(ORInt i = [_vars low];i <= [_vars up];i++) {
      if ([_vars[i] bound]) continue;
      mxp += log([(id)_vars[i] domsize]);
   }
   const ORInt maxProbes = (int)10 * mxp;
   NSLog(@"#vars:  %d --> maximum # probes: %d  (MXP=%f)",probeDepth,maxProbes,mxp);
   int   cntProbes = 0;
   BOOL  carryOn = YES;
   id<ORTracer> tracer = [_cp tracer];
   id<CPIntVarArray> vars = (id<CPIntVarArray>)_vars;//[self allIntVars];
   _aggregator = [[ABSBitVarProbeAggregator alloc] initABSBitVarProbeAggregator:vars];
   _valPr = [ORCrFactory zeroOneStream];
   NSMutableSet* killSet = [[NSMutableSet alloc] initWithCapacity:32];
   NSMutableSet* localKill = [[NSMutableSet alloc] initWithCapacity:32];
   __block ORInt* vs = alloca(sizeof(ORInt)*[[vars range] size]);
   __block ORInt nbVS = 0;
   id<ORZeroOneStream> varPr = [ORCrFactory zeroOneStream];
   do {
      for(ORInt c=0;c <= nbInRound;c++) {
         [_solver clearStatus];
         cntProbes++;
         ABSBitVarProbe* probe = [[ABSBitVarProbe alloc] initABSBitVarProbe:vars];
         ORInt depth = 0;
         BOOL allBound = NO;
         while (depth <= probeDepth && !allBound) {
            [tracer pushNode];
            nbVS = 0;
            [[vars range] enumerateWithBlock:^(ORInt i) {
               if (![vars[i] bound])
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
               id<CPBitVar> xi = (id<CPBitVar>)[vars[i] dereference];
               ORInt v = [self chooseValue:xi];
               ORStatus s = [_solver enforce: ^ORStatus { return [xi bind:v];}];
               [ORConcurrency pumpEvents];
               __block int nbActive = 0;
               [_monitor scanActive:^(CPVarInfo * vInfo) {
                  nbActive++;
                  [probe addVar:[vInfo getVar]];
               }];
               [_aggregator addAssignment:xi toValue:v withActivity:nbActive];
               if (s == ORFailure) {
                  if (depth == 0) {
                     ABSBitVarNogood* nogood = [[ABSBitVarNogood alloc] initABSBitVarNogood:xi value:v];
                     //NSLog(@"Adding SAC %@",nogood);
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
               NSLog(@"after updatePrimalBound = %@",[_solver objective]);
            }
         }
         while (depth-- != 0)
            [tracer popNode];
         //NSLog(@"THEPROBE: %@",probe);
         [_aggregator addProbe:probe];
         [probe release];
         for(ABSBitVarNogood* b in localKill) {
            [_solver enforce: ^ORStatus { return [[b variable] remove:[b value]];}];
            //NSLog(@"Imposing local SAC %@",b);
         }
         [localKill removeAllObjects];
      }
      carryOn = [self moreProbes];
   } while (carryOn && cntProbes < maxProbes);
   
   [_solver atomic:^ORStatus {
      NSLog(@"Imposing %ld SAC constraints",[killSet count]);
      for(ABSBitVarNogood* b in killSet) {
         [_solver enforce: ^ORStatus { return [[b variable] remove:[b value]];}];
      }
      return ORSuspend;
   }];
   
   NSLog(@"Done probing (%d / %d)...",cntProbes,maxProbes);
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
         ABSBitVarActivity* act = [_varBackup objectForKey:key];
         [_varActivity setObject:[act copy] forKey:key];
      }
      for(NSNumber* key in _valBackup) {
         ABSBitVarValueActivity* act = [_valBackup objectForKey:key];
         [_valActivity setObject:[act copy] forKey:key];
      }
   }
}
@end
