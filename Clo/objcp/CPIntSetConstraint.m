/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import "ORConstraintI.h"
#import "CPIntSetConstraint.h"
#import "CPIntVarI.h"
#import "CPRealVarI.h"
#import "CPEngineI.h"

@implementation CPISInterAC

-(id)init:(id<CPIntSetVar>)x inter:(id<CPIntSetVar>)y eq:(id<CPIntSetVar>)z
{
   self = [super initCPCoreConstraint:[x engine]];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(void) post
{
   ORInt v;
   @autoreleasepool {
      id<IntEnumerator> zi = [[_z possible] autorelease];
      while(zi.more) {
         v = zi.next;
         if ([_x isExcluded:v] || [_y isExcluded:v])
            [_z exclude:v];
      }
      zi = [[_z required] autorelease];
      while(zi.more) {
         v = zi.next;
         [_x require:v];
         [_y require:v];
      }
      id<IntEnumerator> xi = [[_x required] autorelease];
      while(xi.more) {
         v = xi.next;
         if ([_y isRequired:v])
            [_z require:v];
      }
      xi = [[_x possible] autorelease];
      while(xi.more) {
         v = xi.next;
         if ([_y isRequired:v] && [_z isExcluded:v])
            [_x exclude:v];
      }
      id<IntEnumerator> yi = [[_y possible] autorelease];
      while(yi.more) {
         v = yi.next;
         if ([_x isRequired:v] && [_z isExcluded:v])
            [_y exclude:v];
      }
      [_x whenExcluded:self do:^(ORInt v) {
         [_z exclude:v];
      }];
      [_x whenRequired:self do:^(ORInt v) {
         if ([_y isRequired:v])
            [_z require:v];
      }];
      [_y whenExcluded:self do:^(ORInt v) {
         [_z exclude:v];
      }];
      [_y whenRequired:self do:^(ORInt v) {
         if ([_x isRequired:v])
            [_z require:v];
      }];
      [_z whenExcluded:self do:^(ORInt v) {
         if ([_x isRequired:v])
            [_y exclude:v];
         if ([_y isRequired:v])
            [_x exclude:v];
      }];
      [_z whenRequired:self do:^(ORInt v) {
         [_x require:v];
         [_y require:v];
      }];      
   }
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
-(ORUInt)nbUVars
{
   return ![_x bound] + ![_y bound] + ![_z bound];
}

@end
