/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import "ORModelI.h"

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

-(ORInt)virtualOffset:(id)obj
{
   return 0;
}
@end
