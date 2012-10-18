/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPABS.h"
#import "CPEngineI.h"
#import "CPIntVarI.h"
#import "CPStatisticsMonitor.h"
#import "ORTracer.h"


@interface ABSNogood : NSObject {
   id<CPIntVar> _var;
   ORInt        _val;
}
-(id)initABSNogood:(id<CPIntVar>)var value:(ORInt)val;
-(id<CPIntVar>)variable;
-(ORInt)value;
@end

@interface ABSProbe : NSObject {
   ORInt*            _tab;
   int                _sz;
   int               _low;
   NSMutableSet* _inProbe;
}
-(ABSProbe*)initABSProbe:(id<ORVarArray>)vars;
-(void)dealloc;
-(void)addVar:(id<ORVar>)var;
-(void)scanProbe:(void(^)(ORInt varID,ORInt activity))block;
@end

@interface ABSProbeAggregator : NSObject {
   id<ORVarArray>    _vars;
   ORInt*            _sum;
   ORInt*          _sumsq;
   int                _sz;
   int               _low;
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
@end

@interface ABSVariableActivity : NSObject {
   @package
   id        _theVar;
   ORFloat _activity;
}
-(id)initABSVariableActivity:(id)var activity:(ORFloat)initial;
-(void)dealloc;
-(void)aging:(ORFloat)rate;
-(ORFloat)activity;
-(void)increase;
@end

@interface ABSValueActivity : NSObject {
   id                    _theVar;
   NSMutableDictionary*  _values;
}
-(id)initABSActivity:(id)var;
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
   _sz  = (ORInt)[vars count];
   _low = [vars low];
   _sum   = malloc(sizeof(ORInt)*_sz);
   _sumsq = malloc(sizeof(ORInt)*_sz);
   memset(_sum,0,sizeof(ORInt)*_sz);
   memset(_sumsq,0,sizeof(ORInt)*_sz);
   _sum -= _low;
   _sumsq -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   _nbProbes = 0;
   _values = [[NSMutableDictionary alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   _sum += _low;
   _sumsq += _low;
   free(_sum);
   free(_sumsq);
   [_inProbe release];
   [_values release];
   [super dealloc];
}
-(void)addProbe:(ABSProbe*)p
{
   [p scanProbe:^(ORInt varID, ORInt activity) {
      NSNumber* key = [[NSNumber alloc] initWithInt:varID];
      [_inProbe addObject:key];
      [key release];
      _sum[varID - _low]   += activity;
      _sumsq[varID - _low] += activity * activity;
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
   return ((ORFloat)_sum[x - _low]) / _nbProbes;
}
-(ORFloat)avgSQActivity:(ORInt)x
{
   return ((ORFloat)_sumsq[x - _low]) / _nbProbes;
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
   _sz  = (ORInt)[vars count];
   _low = [vars low];
   _tab = malloc(sizeof(ORInt)*_sz);
   memset(_tab,0,sizeof(ORInt)*_sz);
   _tab -= _low;
   _inProbe = [[NSMutableSet alloc] initWithCapacity:32];
   return self;
}
-(void)dealloc
{
   _tab -= _low;
   free(_tab);
   [_inProbe release];
   [super dealloc];
}
-(void)addVar:(id<ORVar>)var
{
   ORInt idx = [var getId];
   NSNumber* vid = [[NSNumber alloc]  initWithInt:idx];
   [_inProbe addObject:vid];
   [vid release];
   _tab[idx - _low] += 1;
}
-(void)scanProbe:(void(^)(ORInt varID,ORInt activity))block
{
   for(NSNumber* key in _inProbe)
      block([key intValue],_tab[[key intValue] - _low]);
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
   [_values enumerateKeysAndObjectsUsingBlock:block];
}

-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ValueActivity(%@) = [",_theVar];
   [_values enumerateKeysAndObjectsUsingBlock:^(NSNumber* value, NSNumber* act, BOOL *stop) {
      [buf appendFormat:@"%@ : %@,",value,act];
   }];
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
   ORFloat                      _agingRate;
   ORFloat                      _conf;
   id<ORZeroOneStream>          _valPr;
   ABSProbeAggregator*          _aggregator;
}
-(id)initCPABS:(id<CPSolver>)cp restricted:(id<ORVarArray>)rvars
{
   self = [super init];
   _cp = cp;
   _solver = (CPEngineI*)[cp engine];
   _monitor = nil;
   _vars = nil;
   _rvars = rvars;
   _agingRate = 0.999;
   _conf      = 0.1;
   [cp addHeuristic:self];
   return self;
}
-(void)dealloc
{
   [_varActivity release];
   [_valActivity release];
   [_aggregator release];
   [super dealloc];
}
-(id<CPSolver>)solver
{
   return _cp;
}
-(float)varOrdering:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSVariableActivity* varAct  = [_varActivity objectForKey:key];
   ORFloat rv = [varAct activity];
   [key release];
   return rv / [x domsize];
}
-(float)valOrdering:(int)v forVar:(id<CPIntVar>)x
{
   NSNumber* key = [[NSNumber alloc] initWithInt:[x getId]];
   ABSValueActivity* vAct = [_valActivity objectForKey:key];
   ORFloat rv = [vAct activityForValue:v];
   [key release];
   return - rv;
}
-(void)updateActivities:(id<ORVar>)forVar andVal:(ORInt)val
{
   [_varActivity enumerateKeysAndObjectsUsingBlock:^(NSNumber* key, ABSVariableActivity* act, BOOL *stop) {
      if (![act->_theVar bound]) {
         [act aging:_agingRate];
      }
   }];
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
}
-(void)initInternal:(id<ORVarArray>)t
{
   _vars = t;
   _monitor = [[CPStatisticsMonitor alloc] initCPMonitor:_cp vars:_vars];
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
      ORInt v    = b.min + floor(p / (1.0 / (b.max - b.min + 1)));
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
      more |= (low > lowCI || up < upCI );
      if (more)
         break;
   }
   NSLog(@"|PROBEs| = %d more = %s",nbProbes,more ? "YES" : "NO");
   return more;
}
-(void)installActivities
{
   NSSet* varIDs = [_aggregator variableIDs];
   id<CPIntVarArray> vars = [self allIntVars];
   ORInt nbProbes = [_aggregator nbProbes];
   for(NSNumber* key in varIDs) {
      id<CPIntVar> x = vars[[key intValue]];
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

-(void)initActivities
{
   const ORInt nbInRound = 10;
   const ORInt probeDepth = (ORInt) [_vars count];
   float mxp = 0;
   for(ORInt i = [_vars low];i <= [_vars up];i++) {
      if ([_vars[i] bound]) continue;
      mxp += log([(id)_vars[i] domsize]);
   }
   const int maxProbes = (int)10 * mxp;
   int   cntProbes = 0;
   BOOL  carryOn = YES;
   id<ORTracer> tracer = [_cp tracer];
   id<CPIntVarArray> vars = [self allIntVars];
   _aggregator = [[ABSProbeAggregator alloc] initABSProbeAggregator:vars];
   id<ORSelect> varSel = [ORFactory selectRandom:nil range:[vars range] suchThat:^bool(ORInt i) { return ![vars[i] bound];} orderedBy:nil];
   _valPr = [ORCrFactory zeroOneStream];
   NSMutableSet* killSet = [[NSMutableSet alloc] initWithCapacity:32];
   do {
      for(ORInt c=0;c < nbInRound;c++) {
         [_solver clearStatus];
         cntProbes++;
         ABSProbe* probe = [[ABSProbe alloc] initABSProbe:vars];
         ORInt depth = 0;
         while (depth <= probeDepth) {
            [tracer pushNode];
            ORInt i = [varSel any];
            if (i != MAXINT) { // we found someone
               id<CPIntVar> xi = vars[i];
               ORInt v = [self chooseValue:xi];
               ORStatus s = [_solver label:xi with:v];
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
                     NSLog(@"Adding SAC %@",nogood);
                     [killSet addObject:nogood];
                     [nogood release];
                  }
                  depth++;
                  break;
               }
            }
            depth++;
         }
         if (depth > probeDepth  && [_solver objective]==nil) {
            NSLog(@"Found a solution in a CSP while probing!");
            return ;
         }
         while (depth-- != 0)
            [tracer popNode];
         [_aggregator addProbe:probe];
         [probe release];
      }
      carryOn = [self moreProbes];
   } while (carryOn && cntProbes < 10 * maxProbes);
   for(ABSNogood* b in killSet) {
      [_solver diff:[b variable] with:[b value]];
      NSLog(@"Imposing SAC %@",b);
   }
   [killSet release];
   [varSel release];
   [_valPr release];
}
@end
