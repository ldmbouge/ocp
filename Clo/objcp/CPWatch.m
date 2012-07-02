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
#import "CPSolverI.h"
#import "CPI.h"

@implementation CPWatch
-(CPWatch*)initCPWatch:(id<CPIntVar>)x onValueLost:(CPInt2Void)lost 
           onValueBind:(CPInt2Void)bind 
        onValueRecover:(CPInt2Void)rec 
         onValueUnbind:(CPInt2Void)unb
{
   self = [super initCPActiveConstraint:(id<CPSolver>)[(CPIntVarI*)x solver]];
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
   return [[NSSet alloc] initWithObjects:_theVar,nil];
}
-(CPUInt)nbUVars
{
   return ![_theVar bound];
}

-(CPStatus) post
{
   [_theVar whenLoseValue:self do:^CPStatus(CPInt val) {
      if (_lost) _lost(val);
      if (_rec) {
         [_trail trailClosure:^{
            _rec(val);
         }];
      }
      return CPSuspend;
   }];
   [_theVar setBindTrigger: ^CPStatus(void) { 
      CPInt val = [_theVar min];
      if (_bind) _bind(val);
      if (_unb) {
         [_trail trailClosure:^{
            _unb(val);
         }];
      }
      return CPSuspend;
   } onBehalf:self];
   return CPSuspend;
}
@end

@implementation CPFactory(Visualize)
+(id<CPConstraint>)watchVariable:(id<CPIntVar>)x 
                     onValueLost:(CPInt2Void)lost 
                     onValueBind:(CPInt2Void)bind 
                  onValueRecover:(CPInt2Void)rec 
                   onValueUnbind:(CPInt2Void)unb
{
   id<CPConstraint> c = nil;
   c = [[CPWatch alloc] initCPWatch:x 
                        onValueLost:lost 
                        onValueBind:bind
                     onValueRecover:rec
                      onValueUnbind:unb];
   CPIntVarI* theVar = (CPIntVarI*)x;
   [[theVar solver] trackObject:c];
   return c;
}
@end



@implementation CPViewController
-(CPViewController*)initCPViewController:(id<CPSearchController>)chain onChoose:(CPClosure)onc onFail:(CPClosure)onf
{
   self = [super initCPDefaultController];
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
-(CPInt)addChoice: (NSCont*) k
{
   if (_onChoose)
      _onChoose();
   CPInt cn = [_controller addChoice:k];
   return cn;
}
-(void)fail
{
   if (_onFail)
      _onFail();
   [_controller fail];
}
@end
