/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORSplitVisitor.h"
#import <ORProgram/CPSolver.h>

@implementation ORSplitVisitor{
   CPCoreSolver*   _program;
   id<ORVar>           _variable;
}

-(ORSplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v
{
   self = [super init];
   _program = p;
   _variable = v;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   ORInt mid = (xi.min + xi.max)/2;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,mid);
      [_program label:(id<ORIntVar>)_variable with:mid];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,mid);
      [_program diff:(id<ORIntVar>)_variable with:mid];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid = theMin; //force to the left side if next(theMin) == theMax
   if(fp_next_float(theMin) != theMax){
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      mid = tmpMin/2 + tmpMax/2;
   }
   if(mid == theMax)
      mid = theMin;
   assert(mid != NAN && mid <= xi.max && mid >= xi.min);
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x > %16.16e",[[_program explorer] nbChoices],xi,mid);
      [_program floatGthenImpl:xi with:mid];//CPCommonProgram
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x <= %16.16e",[[_program explorer] nbChoices],xi,mid);
      [_program floatLEqualImpl:xi with:mid];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   ORDouble theMax = xi.max;
   ORDouble theMin = xi.min;
   ORDouble mid = theMin; //force to the left side if next(theMin) == theMax
   if(fp_next_double(theMin) != theMax){
      ORDouble tmpMax = (theMax == +infinity()) ? maxnormal() : theMax;
      ORDouble tmpMin = (theMin == -infinity()) ? -maxnormal() : theMin;
      assert(!(is_infinity(tmpMax) && is_infinity(tmpMin)));
      mid = tmpMin/2 + tmpMax/2;
   }
   if(mid == theMax)
      mid = theMin;
   assert(mid != NAN && mid <= xi.max && mid >= xi.min);
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x > %16.16e",[[_program explorer] nbChoices],xi,mid);
      [_program doubleGthenImpl:xi with:mid];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x <= %16.16e",[[_program explorer] nbChoices],xi,mid);
      [_program doubleLEqualImpl:xi with:mid];
   }];
}
@end


@implementation OR3WaySplitVisitor{
   CPCoreSolver*       _program;
   id<ORVar>           _variable;
}

-(OR3WaySplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v
{
   self = [super init];
   _program = p;
   _variable = v;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   ORInt mid = (xi.min + xi.max)/2;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,mid);
      [_program label:(id<ORIntVar>)_variable with:mid];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,mid);
      [_program diff:(id<ORIntVar>)_variable with:mid];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid;
   ORInt length = 1;
   float_interval interval[3];
   if(fp_next_float(theMin) == theMax){
      interval[0].inf = interval[0].sup = theMin;
      interval[1].inf = interval[1].sup = theMax;
   }else{
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      interval[1].inf  = mid;
      interval[1].sup = mid;
      interval[0].inf  = theMin;
      interval[0].sup = fp_previous_float(mid);
      interval[2].inf = fp_next_float(mid);
      interval[2].sup = theMax;
      length++;
   }
   float_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(3split) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   ORDouble theMax = xi.max;
   ORDouble theMin = xi.min;
   ORDouble mid;
   ORInt length = 1;
   double_interval interval[3];
   if(fp_next_double(theMin) == theMax){
      interval[0].inf = interval[0].sup = theMin;
      interval[1].inf = interval[1].sup = theMax;
   }else{
      ORDouble tmpMax = (theMax == +infinity()) ? maxnormal() : theMax;
      ORDouble tmpMin = (theMin == -infinity()) ? -maxnormal() : theMin;
      mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinity(tmpMax) && is_infinity(tmpMin)));
      interval[1].inf  = mid;
      interval[1].sup = mid;
      interval[0].inf  = theMin;
      interval[0].sup = fp_previous_double(mid);
      interval[2].inf = fp_next_double(mid);
      interval[2].sup = theMax;
      length++;
   }
   double_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(3split) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program doubleIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
@end



@implementation OR5WaySplitVisitor{
   CPCoreSolver*       _program;
   id<ORVar>           _variable;
}

-(OR5WaySplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v
{
   self = [super init];
   _program = p;
   _variable = v;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   ORInt mid = (xi.min + xi.max)/2;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,mid);
      [_program label:(id<ORIntVar>)_variable with:mid];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,mid);
      [_program diff:(id<ORIntVar>)_variable with:mid];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   float_interval interval[5];
   ORInt length = 0;
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORFloat mid;
   length = 1;
   interval[0].inf = interval[0].sup = theMax;
   interval[1].inf = interval[1].sup = theMin;
   if(fp_next_float(theMin) == fp_previous_float(theMax)){
      mid = fp_next_float(theMin);
      interval[2].inf = interval[2].sup = mid;
      length = 2;
   }else{
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
//      todo decomment when bugs are fixed
      if ((theMin < 0.0f) && (0.0f < theMax))// Cpjm
         mid = 0.0f;
      else if ((theMin < 1.0f) && (1.0f < theMax))
         mid = 1.0f;
      else if ((theMin < -1.0f) && (-1.0f < theMax))
         mid = -1.0f;
      else
         mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      //force the interval to right side
      if(mid == fp_previous_float(theMax)){
         mid = fp_previous_float(mid);
      }
      interval[2].inf = interval[2].sup = mid;
//      if(mid == 0.0f)
//         interval[2].inf = -0.0;
      interval[3].inf = fp_next_float(mid);
      interval[3].sup = fp_previous_float(theMax);
      length = 3;
      if(fp_next_float(theMin) != mid){
         interval[4].inf = fp_next_float(theMin);
         interval[4].sup = fp_previous_float(mid);
         length++;
      }
   }
   float_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt index) {
      ORInt c = [[_program explorer] nbChoices];
      LOG([_program debugLevel],1,@"(5split) #choices:%d %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [xi getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
      [_program floatIntervalImpl:xi low:ip[index].inf up:ip[index].sup];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   double_interval interval[5];
   ORInt length = 0;
   ORDouble theMax = xi.max;
   ORDouble theMin = xi.min;
   ORDouble mid;
   length = 1;
   interval[0].inf = interval[0].sup = theMax;
   interval[1].inf = interval[1].sup = theMin;
   if(fp_next_double(theMin) == fp_previous_double(theMax)){
      mid = fp_next_double(theMin);
      interval[2].inf = interval[2].sup = mid;
      length = 2;
   }else{
      ORDouble tmpMax = (theMax == +infinity()) ? maxnormal() : theMax;
      ORDouble tmpMin = (theMin == -infinity()) ? -maxnormal() : theMin;
      if ((theMin < 0.0f) && (0.0f < theMax))// Cpjm
         mid = 0.0f;
      else if ((theMin < 1.0f) && (1.0f < theMax))
         mid = 1.0f;
      else if ((theMin < -1.0f) && (-1.0f < theMax))
         mid = -1.0f;
      else
         mid = tmpMin/2 + tmpMax/2;
      assert(!(is_infinity(tmpMax) && is_infinity(tmpMin)));
      //force the interval to right side
      if(mid == fp_previous_double(theMax)){
         mid = fp_previous_double(mid);
      }
      interval[2].inf = interval[2].sup = mid;
//      if(mid == 0.0)
//         interval[2].inf = -0.0;
      interval[3].inf = fp_next_double(mid);
      interval[3].sup = fp_previous_double(theMax);
      length = 3;
      if(fp_next_float(theMin) != mid){
         interval[4].inf = fp_next_double(theMin);
         interval[4].sup = fp_previous_double(mid);
         length++;
      }
   }
   double_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt index) {
      LOG([_program debugLevel],1,@"(5split) #choices:%d %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [xi getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
      [_program doubleIntervalImpl:xi low:ip[index].inf up:ip[index].sup];
   }];
}
@end



@implementation OR6WaySplitVisitor{
   CPCoreSolver*       _program;
   id<ORVar>           _variable;
}

-(OR6WaySplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v
{
   self = [super init];
   _program = p;
   _variable = v;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   ORInt mid = (xi.min + xi.max)/2;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,mid);
      [_program label:(id<ORIntVar>)_variable with:mid];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,mid);
      [_program diff:(id<ORIntVar>)_variable with:mid];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   float_interval interval[6];
   ORFloat theMax = xi.max;
   ORFloat theMin = xi.min;
   ORBool minIsInfinity = (theMin == -infinityf()) ;
   ORBool maxIsInfinity = (theMax == infinityf()) ;
   ORBool only2float = (fp_next_float(theMin) == theMax);
   ORBool only3float = (fp_next_float(theMin) == fp_previous_float(theMax));
   interval[0].inf = interval[0].sup = theMax;
   ORInt length = 1;
   if(!(only2float || only3float)){
      //au moins 4 floatants
      ORFloat tmpMax = (theMax == +infinityf()) ? maxnormalf() : theMax;
      ORFloat tmpMin = (theMin == -infinityf()) ? -maxnormalf() : theMin;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      
      assert(!(is_infinityf(tmpMax) && is_infinityf(tmpMin)));
      ORFloat midInf = -0.0f;
      ORFloat midSup = +0.0f;
      if(!((minIsInfinity && maxIsInfinity) || (minIsInfinity && !mid) || (maxIsInfinity && ! mid))){
         midInf = fp_nextafterf(mid,-INFINITY);
         midSup = mid;
      }
      ORFloat midSupNext = nextafterf(midSup,+INFINITY);
      ORFloat supPrev = nextafterf(theMax,-INFINITY);
      ORFloat midInfPrev = nextafterf(midInf,-INFINITY);
      ORFloat infNext = nextafterf(theMin,+INFINITY);
      
      interval[2].inf = interval[2].sup = midSup;
      interval[3].inf = interval[3].sup = midInf;
      interval[1].inf = interval[1].sup = theMin;
      length+=3;
      if(midSupNext != supPrev){
         interval[length].inf = midSupNext;
         interval[length].sup = supPrev;
         length++;
      }
      if(midInfPrev != infNext){
         interval[length].sup = midInfPrev;
         interval[length].inf = infNext;
         length++;
      }
   }else if(only2float){
      if(is_eqf(theMax,+0.0f) || is_eqf(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0f;
         interval[2].inf = interval[2].sup = -0.0f;
         length += 2;
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }else{
      //forcement 3 floattants
      if(is_eqf(theMax,+0.0f) || is_eqf(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0f;
         interval[2].inf = interval[2].sup = -0.0f;
         length += 2;
      }else{
         ORFloat mid = nextafterf(theMin,+INFINITY);
         interval[1].inf = interval[1].sup = mid;
         length++;
         
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }
   float_interval* ip = interval;
   length--;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt index) {
      LOG([_program debugLevel],1,@"(6split) #choices:%d %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [xi getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
      [_program floatIntervalImpl:xi low:ip[index].inf up:ip[index].sup];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   double_interval interval[6];
   ORDouble theMax = xi.max;
   ORDouble theMin = xi.min;
   ORBool minIsInfinity = (theMin == -infinity()) ;
   ORBool maxIsInfinity = (theMax == infinity()) ;
   ORBool only2float = (fp_next_double(theMin) == theMax);
   ORBool only3float = (fp_next_double(theMin) == fp_previous_double(theMax));
   interval[0].inf = interval[0].sup = theMax;
   ORInt length = 1;
   if(!(only2float || only3float)){
      //au moins 4 floatants
      ORDouble tmpMax = (theMax == +infinity()) ? maxnormal() : theMax;
      ORDouble tmpMin = (theMin == -infinity()) ? -maxnormal() : theMin;
      ORDouble mid = tmpMin/2 + tmpMax/2;
      
      assert(!(is_infinity(tmpMax) && is_infinity(tmpMin)));
      ORDouble midInf = -0.0;
      ORDouble midSup = +0.0;
      if(!((minIsInfinity && maxIsInfinity) || (minIsInfinity && !mid) || (maxIsInfinity && ! mid))){
         midInf = fp_nextafter(mid,-INFINITY);
         midSup = mid;
      }
      ORDouble midSupNext = nextafter(midSup,+INFINITY);
      ORDouble supPrev = nextafter(theMax,-INFINITY);
      ORDouble midInfPrev = nextafter(midInf,-INFINITY);
      ORDouble infNext = nextafter(theMin,+INFINITY);
      
      interval[2].inf = interval[2].sup = midSup;
      interval[3].inf = interval[3].sup = midInf;
      interval[1].inf = interval[1].sup = theMin;
      length+=3;
      if(midSupNext != supPrev){
         interval[length].inf = midSupNext;
         interval[length].sup = supPrev;
         length++;
      }
      if(midInfPrev != infNext){
         interval[length].sup = midInfPrev;
         interval[length].inf = infNext;
         length++;
      }
   }else if(only2float){
      if(is_eq(theMax,+0.0) || is_eq(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0;
         interval[2].inf = interval[2].sup = -0.0;
         length += 2;
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }else{
      //forcement 3 floattants
      if(is_eq(theMax,+0.0) || is_eq(theMin,-0.0)){
         interval[1].inf = interval[1].sup = +0.0;
         interval[2].inf = interval[2].sup = -0.0;
         length += 2;
      }else{
         ORDouble mid = nextafter(theMin,+INFINITY);
         interval[1].inf = interval[1].sup = mid;
         length++;
         
      }
      interval[length].inf = interval[length].sup = theMin;
      length++;
   }
   double_interval* ip = interval;
   length--;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt index) {
      LOG([_program debugLevel],1,@"(6split) #choices:%d %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [xi getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
      [_program doubleIntervalImpl:xi low:ip[index].inf up:ip[index].sup];
   }];
}
@end


@implementation ORDeltaSplitVisitor{
   CPCoreSolver*       _program;
   id<ORVar>           _variable;
   ORInt               _nb;
}

-(ORDeltaSplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt)nb
{
   self = [super init];
   _program = p;
   _variable = v;
   _nb = nb;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program label:(id<ORIntVar>)_variable with:xi.min];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program diff:(id<ORIntVar>)_variable with:xi.min];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   float_interval interval[5];
   ORInt length = 1;
   if(fp_next_float(xi.min) == xi.max){
      updateFTWithValues(&interval[0], xi.min, xi.min);
      updateFTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
      ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      ORFloat deltaMin = next_nb_float(tmpMin,_nb- (xi.min == -infinityf()),mid);
      ORFloat deltaMax = previous_nb_float(tmpMax,_nb - (xi.max == +infinityf()),fp_next_float(mid));
      updateFTWithValues(&interval[0],xi.min,deltaMin);
      updateFTWithValues(&interval[1],deltaMax,xi.max);
      length++;
      if(deltaMin < mid && deltaMax > mid){
         updateFTWithValues(&interval[2],mid,mid);
         length++;
         if(fp_next_float(deltaMin) != fp_previous_float(mid)){
            updateFTWithValues(&interval[3],fp_next_float(deltaMin),fp_previous_float(mid));
            length++;
         }
         if(deltaMax > fp_next_float(mid)){
            updateFTWithValues(&interval[4],fp_next_float(mid),fp_previous_float(deltaMax));
            length++;
         }
      }
   }
   float_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(Dsplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   double_interval interval[5];
   ORInt length = 1;
   if(fp_next_double(xi.min) == xi.max){
      updateDTWithValues(&interval[0], xi.min, xi.min);
      updateDTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORDouble tmpMax = (xi.max == +infinity()) ? maxnormal() : xi.max;
      ORDouble tmpMin = (xi.min == -infinity()) ? -maxnormal() : xi.min;
      ORDouble mid = tmpMin/2 + tmpMax/2;
      ORDouble deltaMin = next_nb_double(tmpMin,_nb - (xi.min == -infinity()),mid);
      ORDouble deltaMax = previous_nb_double(tmpMax,_nb - (xi.max == +infinity()),fp_next_double(mid));
      updateDTWithValues(&interval[0],xi.min,deltaMin);
      updateDTWithValues(&interval[1],deltaMax,xi.max);
      length++;
      if(deltaMin < mid && deltaMax > mid){
         updateDTWithValues(&interval[2],mid,mid);
         length++;
         if(fp_next_double(deltaMin) != fp_previous_double(mid)){
            updateDTWithValues(&interval[3],fp_next_double(deltaMin),fp_previous_double(mid));
            length++;
         }
         if(deltaMax > fp_next_double(mid)){
            updateDTWithValues(&interval[4],fp_next_double(mid),fp_previous_double(deltaMax));
            length++;
         }
      }
   }
   double_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(Dsplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program doubleIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
@end


@implementation OREnumSplitVisitor{
   CPCoreSolver*       _program;
   id<ORVar>           _variable;
   ORInt               _nb;
}

-(OREnumSplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v nb:(ORInt)nb
{
   self = [super init];
   _program = p;
   _variable = v;
   _nb = nb;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program label:(id<ORIntVar>)_variable with:xi.min];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program diff:(id<ORIntVar>)_variable with:xi.min];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) xi
{
   if([xi bound]) return;
   ORInt nb = 2*_nb+4;
   float_interval interval[nb];//to check + assert
   ORInt length = 1;
   if(fp_next_float(xi.min) == xi.max){
      updateFTWithValues(&interval[0], xi.min, xi.min);
      updateFTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORFloat tmpMax = (xi.max == +infinityf()) ? maxnormalf() : xi.max;
      ORFloat tmpMin = (xi.min == -infinityf()) ? -maxnormalf() : xi.min;
      ORFloat mid = tmpMin/2 + tmpMax/2;
      ORFloat deltaMin = next_nb_float(tmpMin,_nb - (xi.min == -infinityf()),mid);
      ORFloat deltaMax = previous_nb_float(tmpMax,_nb - (xi.max == +infinityf()),fp_next_float(mid));
      for(ORFloat v = xi.min; v <= deltaMin; v = fp_next_float(v)){
         updateFTWithValues(&interval[length-1], v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      for(ORFloat v = xi.max; v >= deltaMax; v = fp_previous_float(v)){
         updateFTWithValues(&interval[length-1],v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      if(deltaMin < mid && deltaMax > mid){
         updateFTWithValues(&interval[length-1], mid,mid);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
         if(fp_next_float(deltaMin) != fp_previous_float(mid)){
            updateFTWithValues(&interval[length-1],fp_next_float(deltaMin),fp_previous_float(mid));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
         if(deltaMax > fp_next_float(mid)){
            updateFTWithValues(&interval[length-1],fp_next_float(mid),fp_previous_float(deltaMax));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
      }
   }
   float_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(Esplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program floatIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
-(void) applyDoubleSplit :(CPDoubleVarI*) xi
{
   if([xi bound]) return;
   ORInt nb = 2*_nb+4;
   double_interval interval[nb];//to check + assert
   ORInt length = 1;
   if(fp_next_double(xi.min) == xi.max){
      updateDTWithValues(&interval[0], xi.min, xi.min);
      updateDTWithValues(&interval[1], xi.max, xi.max);
   }else{
      ORDouble tmpMax = (xi.max == +infinity()) ? maxnormal() : xi.max;
      ORDouble tmpMin = (xi.min == -infinity()) ? -maxnormal() : xi.min;
      ORDouble mid = tmpMin/2 + tmpMax/2;
      ORDouble deltaMin = next_nb_double(tmpMin,_nb - (xi.min == -infinity()),mid);
      ORDouble deltaMax = previous_nb_double(tmpMax,_nb - (xi.max == +infinity()),fp_next_double(mid));
      for(ORDouble v = xi.min; v <= deltaMin; v = fp_next_double(v)){
         updateDTWithValues(&interval[length-1], v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      for(ORDouble v = xi.max; v >= deltaMax; v = fp_previous_double(v)){
         updateDTWithValues(&interval[length-1],v,v);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
      }
      if(deltaMin < mid && deltaMax > mid){
         updateDTWithValues(&interval[length-1], mid,mid);
         assert(length-1 >= 0 && length-1 < nb);
         length++;
         if(fp_next_double(deltaMin) != fp_previous_double(mid)){
            updateDTWithValues(&interval[length-1],fp_next_double(deltaMin),fp_previous_double(mid));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
         if(deltaMax > fp_next_double(mid)){
            updateDTWithValues(&interval[length-1],fp_next_double(mid),fp_previous_double(deltaMax));
            assert(length-1 >= 0 && length-1 < nb);
            length++;
         }
      }
   }
   double_interval* ip = interval;
   [_program tryall:RANGE(_program,0,length) suchThat:nil do:^(ORInt i) {
      LOG([_program debugLevel],1,@"(Esplit) START #choices:%d %@ try x in [%16.16e,%16.16e]",[[_program explorer] nbChoices],xi,ip[i].inf,ip[i].sup);
      [_program doubleIntervalImpl:xi low:ip[i].inf up:ip[i].sup];
   }];
}
@end

@implementation ORAbsSplitVisitor{
   CPCoreSolver*           _program;
   id<ORVar>           _variable;
   id<CPVar>           _other;
}

-(ORAbsSplitVisitor*) initWithProgram : (CPCoreSolver*) p variable:(id<ORVar>) v other:(id<CPVar>)other
{
   self = [super init];
   _program = p;
   _variable = v;
   _other = other;
   return self;
}

-(void) applyIntSplit :(CPIntVarI*) xi;
{
   if([xi bound]) return;
   [_program try: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ try x =  %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program label:(id<ORIntVar>)_variable with:xi.min];
   } alt: ^{
      LOG([_program debugLevel],1,@"START #choices:%d %@ alt x != %d",[[_program explorer] nbChoices],xi,xi.min);
      [_program diff:(id<ORIntVar>)_variable with:xi.min];
   }];
   
}
-(void) applyFloatSplit :(CPFloatVarI*) cx
{
   float_interval interval[18];
   float_interval interval_x[3];
   float_interval interval_y[3];
   ORInt length_x = 0;
   ORInt length_y = 0;
   float_interval ax = computeAbsorbingInterval(cx);
   float_interval ay = computeAbsordedInterval(cx);
   CPFloatVarI* y = (CPFloatVarI*)_other;
   if(! [_other bound]) {
      if(isIntersectingWithV(y.min,y.max,ay.inf,ay.sup)){
         ay.inf = maxFlt(ay.inf, y.min);
         ay.sup = minFlt(ay.sup, y.max);
         length_y = !(y.min == ay.inf) + !(y.max == ay.sup);
         interval_y[0] = ay;
         if(ay.inf > y.min && y.max > ay.sup){
            interval_y[1] = makeFloatInterval(y.min,fp_previous_float(ay.inf));
            interval_y[2] = makeFloatInterval(fp_next_float(ay.sup), y.max);
         }
         else if(ay.inf == [y min]){
            interval_y[1] = makeFloatInterval(fp_next_float(ay.sup),y.max);
         }else {
            interval_y[1] = makeFloatInterval(y.min,fp_previous_float(ay.inf));
         }
      }else{
         interval_y[0] = makeFloatInterval(y.min, y.max);
         length_y = 0;
      }
   }
   length_x = !(cx.min == ax.inf) + !(cx.max == ax.sup);
   interval_x[0].inf = maxFlt(cx.min,ax.inf);
   interval_x[0].sup = minFlt(cx.max,ax.sup);
   ORInt i_x = 1;
   ORFloat xmax = cx.max;
   if(ax.sup ==  cx.max){
      interval_x[1].inf = minFlt(cx.min,fp_next_float(ax.inf));
      interval_x[1].sup = fp_previous_float(ax.inf);
   }else{
      if(-ax.sup < cx.max){
         interval_x[i_x].inf = -ax.sup;
         interval_x[i_x].sup = cx.max;
         xmax = -ax.sup;
         length_x++;
         i_x++;
      }
      interval_x[i_x].inf = fp_next_float(ax.sup);
      interval_x[i_x].sup = fp_previous_float(xmax);
   }
   if(length_y >= 1){
      ORInt length = 0;
      for(ORInt i = 0; i <= length_x;i++){
         for(ORInt j = 0; j <= length_y;j++){
            interval[length] = interval_x[i];
            length++;
            interval[length] = interval_y[j];
            length++;
         }
      }
      float_interval* ip = interval;
      length--;
      [_program tryall:RANGE(_program,0,length/2) suchThat:nil do:^(ORInt index) {
         LOG([_program debugLevel],1,@"#choices:%d %@ in [%16.16e,%16.16e]\t %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[_variable prettyname],ip[2*index].inf,ip[2*index].sup,[NSString stringWithFormat:@"var<%d>", [y getId]],ip[2*index+1].inf,ip[2*index+1].sup);
         [_program floatIntervalImpl:cx low:ip[2*index].inf up:ip[2*index].sup];
         [_program floatIntervalImpl:y low:ip[2*index+1].inf up:ip[2*index+1].sup];
      }];
   }else if (length_x > 0 && length_y == 0){
      float_interval* ip = interval_x;
      [_program tryall:RANGE(_program,0,length_x) suchThat:nil do:^(ORInt index) {
         LOG([_program debugLevel],1,@"#choices:%d  %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
         [_program floatIntervalImpl:cx low:ip[index].inf up:ip[index].sup];
      }];
   }
}
-(void) applyDoubleSplit :(CPDoubleVarI*) cx
{
   double_interval interval[18];
   double_interval interval_x[3];
   double_interval interval_y[3];
   ORInt length_x = 0;
   ORInt length_y = 0;
   double_interval ax = computeAbsorbingIntervalD(cx);
   double_interval ay = computeAbsordedIntervalD(cx);
   CPDoubleVarI* y = (CPDoubleVarI*)_other;
   if(! [_other bound]) {
      if(isIntersectingWithDV(y.min,y.max,ay.inf,ay.sup)){
         ay.inf = maxDbl(ay.inf, y.min);
         ay.sup = minDbl(ay.sup, y.max);
         length_y = !(y.min == ay.inf) + !(y.max == ay.sup);
         interval_y[0] = ay;
         if(ay.inf > y.min && y.max > ay.sup){
            interval_y[1] = makeDoubleInterval(y.min,fp_previous_double(ay.inf));
            interval_y[2] = makeDoubleInterval(fp_next_double(ay.sup), y.max);
         }
         else if(ay.inf == [y min]){
            interval_y[1] = makeDoubleInterval(fp_next_double(ay.sup),y.max);
         }else {
            interval_y[1] = makeDoubleInterval(y.min,fp_previous_double(ay.inf));
         }
      }else{
         interval_y[0] = makeDoubleInterval(y.min, y.max);
         length_y = 0;
      }
   }
   length_x = !(cx.min == ax.inf) + !(cx.max == ax.sup);
   interval_x[0].inf = maxDbl(cx.min,ax.inf);
   interval_x[0].sup = minDbl(cx.max,ax.sup);
   ORInt i_x = 1;
   ORDouble xmax = cx.max;
   if(ax.sup ==  cx.max){
      interval_x[1].inf = minDbl(cx.min,fp_next_double(ax.inf));
      interval_x[1].sup = fp_previous_double(ax.inf);
   }else{
      if(-ax.sup < cx.max){
         interval_x[i_x].inf = -ax.sup;
         interval_x[i_x].sup = cx.max;
         xmax = -ax.sup;
         length_x++;
         i_x++;
      }
      interval_x[i_x].inf = fp_next_double(ax.sup);
      interval_x[i_x].sup = fp_previous_double(xmax);
   }
   if(length_y >= 1){
      ORInt length = 0;
      for(ORInt i = 0; i <= length_x;i++){
         for(ORInt j = 0; j <= length_y;j++){
            interval[length] = interval_x[i];
            length++;
            interval[length] = interval_y[j];
            length++;
         }
      }
      double_interval* ip = interval;
      length--;
      [_program tryall:RANGE(_program,0,length/2) suchThat:nil do:^(ORInt index) {
         LOG([_program debugLevel],1,@"#choices:%d %@ in [%16.16e,%16.16e]\t %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[_variable prettyname],ip[2*index].inf,ip[2*index].sup,[NSString stringWithFormat:@"var<%d>", [y getId]],ip[2*index+1].inf,ip[2*index+1].sup);
         [_program doubleIntervalImpl:cx low:ip[2*index].inf up:ip[2*index].sup];
         [_program doubleIntervalImpl:y low:ip[2*index+1].inf up:ip[2*index+1].sup];
      }];
   }else if (length_x > 0 && length_y == 0){
      double_interval* ip = interval_x;
      [_program tryall:RANGE(_program,0,length_x) suchThat:nil do:^(ORInt index) {
         LOG([_program debugLevel],1,@"#choices:%d  %@ in [%16.16e,%16.16e]",[[_program explorer] nbChoices],([_variable prettyname]==nil)?[NSString stringWithFormat:@"var<%d>", [cx getId]]:[_variable prettyname],ip[index].inf,ip[index].sup);
         [_program doubleIntervalImpl:cx low:ip[index].inf up:ip[index].sup];
      }];
   }
}
@end


@implementation ORAbsVisitor{
   id<CPVar> _var;
   ORDouble  _rate;
}
-(ORAbsVisitor*) init:(id<CPVar>) v
{
   self = [super init];
   _var = v;
   _rate = 0.0;
   return self;
}
-(ORDouble) rate
{
   return _rate;
}

- (void)applyDoubleAbs:(id<CPVar>)x
{
   CPDoubleVarI* cx = (CPDoubleVarI*) x;
   CPDoubleVarI* cy = (CPDoubleVarI*)_var;
   double_interval ax = computeAbsordedIntervalD(cx);
   if(![cy bound] && isIntersectingWithDV(ax.inf, ax.sup, cy.min, cy.max)){
      _rate = (ORDouble)(cardinalityDV(maxDbl(ax.inf,cy.min),minDbl(ax.sup, cy.max))/cardinalityD(cy));
   }
}

- (void)applyFloatAbs:(id<CPVar>)x
{
   CPFloatVarI* cx = (CPFloatVarI*) x;
   CPFloatVarI* cy = (CPFloatVarI*)_var;
   float_interval ax = computeAbsordedInterval(cx);
   if(![cy bound] && isIntersectingWithV(ax.inf, ax.sup, cy.min, cy.max)){
      _rate = cardinalityV(maxFlt(ax.inf,cy.min),minFlt(ax.sup, cy.max))/cardinality(cy);
   }
}

- (void)applyIntAbs:(id<CPVar>)var
{
}

- (void)visit:(ORVisitor *)visitor
{
}

@end

