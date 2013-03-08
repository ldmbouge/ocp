/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPABS.h"
#import "CPEngineI.h"
#import <objcp/CPStatisticsMonitor.h>
#import <ORFoundation/ORTracer.h>

@interface ABSNogood : NSObject {
   id<CPIntVar> _var;
   ORInt        _val;
}
-(id)initABSNogood:(id<CPIntVar>)var value:(ORInt)val;
-(id<CPIntVar>)variable;
-(ORInt)value;
@end

@interface ABSProbe : NSObject {
   ORFloat*          _tab;
   int                _sz;
   int               _low;
   int                _up;
   NSMutableSet* _inProbe;
}
-(ABSProbe*)initABSProbe:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addVar:(id<ORVar>)var;
-(void)scanProbe:(void(^)(ORInt varID,ORFloat activity))block;
@end

@interface ABSProbeAggregator : NSObject {
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
-(ABSProbeAggregator*)initABSProbeAggregator:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addProbe:(ABSProbe*)p;
-(void)addAssignment:(id<CPIntVar>)x toValue:(ORInt)v withActivity:(ORFloat)act;
-(ORInt)nbProbes;
-(ORFloat)avgActivity:(ORInt)x;
-(ORFloat)avgSQActivity:(ORInt)x;
-(NSSet*)variableIDs;
-(void)enumerateForVariabe:(ORInt)x using:(void(^)(id value,id activity,BOOL* stop))block;
-(NSString*)description;
@end

@interface ABSVariableActivity : NSObject<NSCopying> {
   @package
   id        _theVar;
   ORFloat _activity;
}
-(id)initABSVariableActivity:(id)var activity:(ORFloat)initial;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)aging:(ORFloat)rate;
-(ORFloat)activity;
-(void)increase;
@end

@interface ABSValueActivity : NSObject<NSCopying> {
   id                    _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSActivity:(id)var;
-(id)copyWithZone:(NSZone*)zone;
-(void)dealloc;
-(void)setActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addActivity:(ORFloat)a forValue:(ORInt)v;
-(void)addProbeActivity:(ORFloat)a forValue:(ORInt)v;
-(ORFloat)activityForValue:(ORInt)v;
-(void)enumerate:(void(^)(id value,id activity,BOOL* stop))block;
-(NSString*)description;
@end

@implementation ABSProbeAggregator
-(ABSProbeAggregator*)initABSProbeAggregator:(id<ORVarArray>)vars
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
-(void)addProbe:(ABSProbe*)p
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
-(void)addAssignment:(id<CPIntVar>)x toValue:(ORInt)v withActivity:(ORFloat)act
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSValueActivity* valueActivity = [_values objectForKey:key];
   if (valueActivity == nil) {
      valueActivity = [[ABSValueActivity alloc] initABSActivity:x];
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

@implementation ABSNogood
-(id)initABSNogood:(id<CPIntVar>)var value:(ORInt)val
{
   self = [super init];
   _var = var;
   _val = val;
   return self;
}
-(id<CPIntVar>)variable
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

@implementation ABSProbe
-(ABSProbe*)initABSProbe:(id<ORVarArray>)vars
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

@implementation ABSVariableActivity
-(id)initABSVariableActivity:(id)var activity:(ORFloat)initial
{
   self = [super init];
   _theVar = var;
   _activity = initial;
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   return [[ABSVariableActivity alloc] initABSVariableActivity:_theVar activity:_activity];
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

@implementation ABSValueActivity
-(id)initABSActivity:(id)var
{
   self = [super init];
   _theVar = var;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(id)copyWithZone:(NSZone*)zone
{
   ABSValueActivity* copy = [[ABSValueActivity alloc] initABSActivity:_theVar];
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

@implementation CPABS {
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
   ABSProbeAggregator*          _aggregator;
}
-(id)initCPABS:(id<CPCommonProgram>)cp restricted:(id<ORVarArray>)rvars
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
   CPABS* cp = [[CPABS alloc] initCPABS:_cp restricted:_rvars];
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
   ABSVariableActivity* varAct  = [_varActivity objectForKey:key];
   ORFloat rv = [varAct activity];
   [key release];
   return rv / [x domsize];
}
-(ORFloat)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[[x dereference] getId]];
   ABSValueActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v];
   [key release];
   return - rv;
}
-(void)updateActivities:(id<ORVar>)forVar andVal:(ORInt)val
{
   for(NSNumber* key in _varActivity) {
      ABSVariableActivity* act = [_varActivity objectForKey:key];
      if (![act->_theVar bound]) {
         [act aging:_agingRate];
      }
   }
   __block int nbActive = 0;
   [_monitor scanActive:^(CPVarInfo *vInfo) {
      NSNumber* key = [[NSNumber alloc] initWithInt:[vInfo getVarID]];
      ABSVariableActivity* va = [_varActivity objectForKey:key];
      if (!va) {
         va = [[ABSVariableActivity alloc] initABSVariableActivity:[vInfo getVar] activity:0];
         [_varActivity setObject:va forKey:key];
         [va release];
      }
      [key release];
      [va increase];
      ++nbActive;
   }];
   NSNumber* key = [[NSNumber alloc] initWithInt:[forVar getId]];
   ABSValueActivity* valAct = [_valActivity objectForKey:key];
   if (!valAct) {
      valAct = [[ABSValueActivity alloc] initABSActivity:forVar];
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
   NSLog(@"ABS ready...");
}
-(id<CPIntVarArray>)allIntVars
{
   return (id<CPIntVarArray>) (_rvars!=nil ? _rvars : _vars);
}

-(ORInt)chooseValue:(id<CPIntVar>)x
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
         ABSVariableActivity* xAct = [[ABSVariableActivity alloc] initABSVariableActivity:x activity:act];
         [_varActivity setObject:xAct forKey:key];
         [xAct release];
         
         ABSValueActivity*  valAct = [[ABSValueActivity alloc] initABSActivity:x];
         [_valActivity setObject:valAct forKey:key];
         [valAct release];
         [_aggregator enumerateForVariabe:[key intValue] using:^(NSNumber* value, NSNumber* activity, BOOL *stop) {
            [valAct setActivity:[activity floatValue] / nbProbes forValue:[value intValue]];
         }];
      }
   }
   _varBackup = [[NSMutableDictionary alloc] initWithCapacity:[_varActivity count]];
   for(NSNumber* key in _varActivity) {
      ABSVariableActivity* act = [_varActivity objectForKey:key];
      [_varBackup setObject:[act copy] forKey:key];
   }
   _valBackup = [[NSMutableDictionary alloc] initWithCapacity:[_valActivity count]];
   for(NSNumber* key in _valActivity) {
      ABSValueActivity* act = [_valActivity objectForKey:key];
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
   _aggregator = [[ABSProbeAggregator alloc] initABSProbeAggregator:vars];
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
         ABSProbe* probe = [[ABSProbe alloc] initABSProbe:vars];
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
               id<CPIntVar> xi = (id<CPIntVar>)[vars[i] dereference];
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
                     ABSNogood* nogood = [[ABSNogood alloc] initABSNogood:xi value:v];
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
               return ;
            } else {
               NSLog(@"Found a local optimum = %@",[_solver objective]);
               [[_solver objective] updatePrimalBound];
               NSLog(@"after updatePrimalBound = %@",[_solver objective]);
            }
         }
         while (depth-- != 0)
            [tracer popNode];
         //NSLog(@"THEPROBE: %@",probe);
         [_aggregator addProbe:probe];
         [probe release];
         for(ABSNogood* b in localKill) {
            [_solver enforce: ^ORStatus { return [[b variable] remove:[b value]];}];            
            NSLog(@"Imposing local SAC %@",b);
         }
         [localKill removeAllObjects];
      }
      carryOn = [self moreProbes];
   } while (carryOn && cntProbes < maxProbes);
   
   [_solver atomic:^ORStatus {
      for(ABSNogood* b in killSet) {
         [_solver enforce: ^ORStatus { return [[b variable] remove:[b value]];}];
         NSLog(@"Imposing SAC %@",b);
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
         ABSVariableActivity* act = [_varBackup objectForKey:key];
         [_varActivity setObject:[act copy] forKey:key];
      }
      for(NSNumber* key in _valBackup) {
         ABSValueActivity* act = [_valBackup objectForKey:key];
         [_valActivity setObject:[act copy] forKey:key];
      }
   }
}
@end
