/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORModelI.h"
#import "ORError.h"

@implementation ORModelI
{
   NSMutableArray*          _vars;
   NSMutableArray*          _cStore;
   NSMutableArray*          _mStore;
   NSMutableArray*          _oStore;
   ORObjectiveFunctionI*    _objective;
}
-(ORModelI*) initORModelI
{
   self = [super init];
   _vars  = [[NSMutableArray alloc] init];
   _cStore = [[NSMutableArray alloc] initWithCapacity:32];
   _mStore = [[NSMutableArray alloc] initWithCapacity:32];
   _oStore = [[NSMutableArray alloc] initWithCapacity:32];
   _objective = nil;
   return self;
}

-(void) dealloc
{
   NSLog(@"Solver [%p] dealloc called...\n",self);
   [_vars release];
   [_cStore release];
   [_mStore release];
   [_oStore release];
   [_objective release];
   [super dealloc];
}

-(NSString*) description
{
   return [NSString stringWithFormat:@"Model"];
}

-(void) add: (id<ORConstraint>) cstr
{
   
}

-(void) minimize: (id<ORIntVar>) x
{
   
}

-(void) maximize: (id<ORIntVar>) x
{
   
}

-(void) trackObject: (id) obj;
{
   
}

-(void) trackVariable: (id) var;
{
   [var setId: (ORUInt) [_vars count]];
   [_vars addObject:var];
   [var autorelease];
}

-(ORInt) virtualOffset: (id) obj
{
   return 0;
}
@end

@implementation ORIntVarI
{
   id<ORIntVar>   _impl;
   id<ORTracker>  _tracker;
   id<ORIntRange> _domain;
   BOOL           _dense;
   ORUInt         _name;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain
{
   self = [super init];
   _tracker = track;
   _domain = domain;
   _dense = true;
   [track trackVariable: self];
   return self;
}
-(void) dealloc
{
   [super dealloc];   
}
-(void) setId: (ORUInt) name
{
   _name = name;
}
-(ORInt) getId
{
   return _name;
}
-(ORInt) value
{
   return 0;
}
-(ORInt) min
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(ORInt) max
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(ORInt) domsize
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
-(bool) member: (ORInt) v
{
   if (_impl)
      return [_impl min];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
}
-(BOOL) bound
{
   if (_impl)
      return [_impl bound];
   else
      @throw [[ORExecutionError alloc] initORExecutionError: "The variable has no concretization"];
   
}
@end
