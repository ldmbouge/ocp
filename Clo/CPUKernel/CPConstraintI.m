/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <CPUKernel/CPConstraintI.h>
#import "CPEngineI.h"

@implementation CPCoreConstraint
-(CPCoreConstraint*) initCPCoreConstraint:(id<ORSearchEngine>)m
{
   self = [super init];
   _todo = CPChecked;
   _priority = HIGHEST_PRIO;
   _propagate = (SELPROTO)[self methodForSelector:@selector(propagate)];
   _trail = [[m trail] retain];
   _active  = makeTRInt(_trail,true);
   _group = nil;
   return self;
}
-(void)dealloc
{
   [_trail release];
   [super dealloc];
}
-(void) close
{
}
// Constraint method
-(void) post
{
}
-(void) propagate
{}
-(NSSet*)allVars
{
    return [[[NSSet alloc] init] autorelease];
}
-(NSArray*)allVarsArray
{
    return [[[NSArray alloc] init] autorelease];
}
-(ORUInt) nbVars
{
   ORUInt nbv = 0;
   @autoreleasepool {
      NSSet* av = [self allVars];
      nbv = (ORUInt)[av count];
   }
   return nbv;
}
-(ORUInt)nbUVars
{
   ORUInt nbu = 0;
   @autoreleasepool {
      NSSet* av = [self allVars];
      for(id aVar in av) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wobjc-method-access"
         nbu += ![aVar bound];
#pragma clang diagnostic pop
      }
   }
   return nbu;
}
-(void)setGroup:(id<CPGroup>)g
{
   _group = g;
}
-(id<CPGroup>)group
{
   return _group;
}
-(void) toCheck
{
   _todo = CPTocheck;
}
-(ORBool)entailed
{
   return _active._val == NO;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitConstraint:self];
}
-(ORBool) memberVar:(id<ORVar>)x
{
   @autoreleasepool{
      NSSet *vars = [self allVars];
      return [vars containsObject:x];
   }
}
-(ORUInt) nbOccurences:(id<ORVar>)x
{
   @autoreleasepool{
      NSArray *vars = [self allVarsArray];
      ORUInt i = 0;
      for(id<ORVar> v in vars){
        if ([v getId] == [x getId])
            i++;
      }
      return i;
   }
}
-(ORBool) canLeadToAnAbsorption
{
   return false;
}
-(id<CPVar>) varSubjectToAbsorption:(id<CPVar>)x
{
   return nil;
}
-(ORDouble) leadToACancellation:(id<ORVar>)x
{
    return 0.0;
}
@end

