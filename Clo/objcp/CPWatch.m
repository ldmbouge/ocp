/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import "CPWatch.h"
#import "CPConstraintI.h"
#import "CPIntVarI.h"
#import "CPEngineI.h"
#import "CPProgram.h"

@interface CPWatch : CPCoreConstraint {
   CPIntVarI* _theVar;
   ORInt2Void _lost;
   ORInt2Void _bind;
   ORInt2Void _rec;
   ORInt2Void _unb;
}
-(CPWatch*)initCPWatch:(id<CPIntVar>)x onValueLost:(ORInt2Void)lost onValueBind:(ORInt2Void)bind onValueRecover:(ORInt2Void)rec onValueUnbind:(ORInt2Void)unb;
-(ORStatus) post;
-(NSSet*)allVars;
-(ORUInt)nbUVars;
@end

@implementation CPWatch
-(CPWatch*)initCPWatch:(id<CPIntVar>)x onValueLost:(ORInt2Void)lost
           onValueBind:(ORInt2Void)bind 
        onValueRecover:(ORInt2Void)rec 
         onValueUnbind:(ORInt2Void)unb
{
   self = [super initCPCoreConstraint:[(CPIntVarI*)x engine]];
   _theVar = (CPIntVarI*)x;
   _lost = [lost copy];
   _bind = [bind copy];
   _rec = [rec copy];
   _unb = [unb copy];
   _priority = LOWEST_PRIO;
   return self;
}
-(void)dealloc
{
   [_lost release];
   [_bind release];
   [_rec release];
   [_unb release];
   [super dealloc];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_theVar,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_theVar bound];
}

-(ORStatus) post
{
   [_theVar whenLoseValue:self do:^(ORInt val) {
      if (_lost) _lost(val);
      if (_rec) {
         [_trail trailClosure:^{
            _rec(val);
         }];
      }
   }];
   [_theVar setBindTrigger: ^ { 
      ORInt val = [_theVar min];
      if (_bind) _bind(val);
      if (_unb) {
         [_trail trailClosure:^{
            _unb(val);
         }];
      }
   } onBehalf:self];
   return ORSuspend;
}
@end

@implementation CPFactory(Visualize)
+(id<ORConstraint>)solver:(id<CPProgram>)cp
            watchVariable:(id<ORIntVar>)x
              onValueLost:(ORInt2Void)lost
              onValueBind:(ORInt2Void)bind
           onValueRecover:(ORInt2Void)rec
            onValueUnbind:(ORInt2Void)unb
{
   id<ORConstraint> c = nil;
   id<CPIntVar> theVar = [cp gamma][x.getId];
   c = [[CPWatch alloc] initCPWatch:theVar
                        onValueLost:lost 
                        onValueBind:bind
                     onValueRecover:rec
                      onValueUnbind:unb];
   [[theVar engine] trackMutable:c];
   return c;
}
@end



@implementation CPViewController
-(CPViewController*)initCPViewController:(id<ORSearchController>)chain onChoose:(ORClosure)onc onFail:(ORClosure)onf
{
   self = [super initORDefaultController];
   [self setController:chain];
   _onChoose = [onc copy];
   _onFail = [onf copy];
   return self;
}
-(void)dealloc
{
   [_onChoose release];
   [_onFail release];
   [super dealloc];
}
-(ORInt)addChoice: (NSCont*) k
{
   if (_onChoose)
      _onChoose();
   ORInt cn = [_controller addChoice:k];
   return cn;
}
-(void)fail
{
   if (_onFail)
      _onFail();
   [_controller fail];
}
@end
