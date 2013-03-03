/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORTracker.h"
#import "ORFactory.h"
#import "ORControl.h"
#import <math.h>
#import <values.h>


@interface ORForallI : NSObject <ORForall>
-(ORForallI*) initORForallI: (id<ORTracker>) tracker set: (id<ORIntIterable>) S;
-(id<ORForall>) suchThat: (ORInt2Bool) suchThat;
-(id<ORForall>) orderedBy: (ORInt2Int) orderedBy;
-(void) do: (ORInt2Void) body;
@end

@implementation ORForallI 
{
   id<ORTracker>     _tracker;
   id<ORIntIterable> _S;
   NSMutableArray*   _arraySuchThat;
   NSMutableArray*   _arrayOrderedBy;
}
-(ORForallI*) initORForallI: (id<ORTracker>) tracker set: (id<ORIntIterable>) S
{
   self = [super init];
   _tracker = tracker;
   _S = [S retain];
   _arraySuchThat = [[NSMutableArray alloc] initWithCapacity: 1];
   _arrayOrderedBy = [[NSMutableArray alloc] initWithCapacity: 1];
   return self;
}
-(void) dealloc
{
   [_S release];
   [_arraySuchThat release];
   [_arrayOrderedBy release];
   [super dealloc];
}
-(id<ORForall>) suchThat: (ORInt2Bool) suchThat
{
   [_arraySuchThat addObject: suchThat];
   return self;
}
-(id<ORForall>) orderedBy: (ORInt2Int) orderedBy
{
   [_arrayOrderedBy addObject: orderedBy];
   return self;
}
static inline BOOL testSuchThat(ORInt val,NSArray* arraySuchThat)
{
   BOOL valid = true;
   ORInt nb = (ORInt) [arraySuchThat count];
   for(ORInt i = 0; i < nb && valid; i++)
      valid = ((ORInt2Bool) [arraySuchThat objectAtIndex: i])(val);
   return valid;
}
static inline BOOL isSmaller(ORInt val,NSArray* arrayOrderedBy,float* best)
{
   ORInt nb = (ORInt) [arrayOrderedBy count];
   for(ORInt i = 0; i < nb; i++) {
      float e = ((ORInt2Int) [arrayOrderedBy objectAtIndex: i])(val);
      if (e < best[i])
         return true;
      if (e > best[i])
         return false;
   }
   return false;;
}
-(void) do: (ORInt2Void) body
{
   ORInt sz = [_S size];
   ORInt* value = alloca(sizeof(ORInt)*sz);
   bool* used = alloca(sizeof(bool)*sz);
   memset(used,0,sizeof(bool)*sz);
   ORInt nbo = (ORInt) [_arrayOrderedBy count];
   float* best = alloca(sizeof(float)*nbo);
   id<IntEnumerator> ite = [_S enumerator];
   ORInt nb = 0;
   while ([ite more]) {
      value[nb] = [ite next];
      if (testSuchThat(value[nb],_arraySuchThat))
         nb++;
   }
   bool done = false;
   while (!done) {
      for(int k = 0; k < nbo; k++)
         best[k] = MAXFLOAT;
      ORInt chosen = -1;
      ORInt i = 0;
      while (i < nb) {
//         if (!used[i]) && (([_arraySuchThat count] == 0) || (((ORInt2Bool) [_arraySuchThat objectAtIndex: 0])(value[i])))) {
         if (!used[i]) {
            BOOL valid = true;
            ORInt nbs = (ORInt) [_arraySuchThat count];
            for(ORInt k = 0; k < nbs && valid; k++)
               valid = ((ORInt2Bool) [_arraySuchThat objectAtIndex: k])(value[i]);
            if (valid) {
               if (isSmaller(value[i],_arrayOrderedBy,best)) {
                  chosen = i;
                  ORInt nbo = (ORInt) [_arrayOrderedBy count];
                  for(ORInt k = 0; k < nbo; k++) 
                     best[k] = ((ORInt2Int) [_arrayOrderedBy objectAtIndex: k])(value[i]);
               }
            }
         }
         ++i;
      }
      done = (chosen == -1);
      if (!done) {
         used[chosen] = true;
         body(value[chosen]);
      }
   }
}
@end


@implementation ORFactory (Control)
+(id<ORForall>) forall: (id<ORTracker>) tracker set: (id<ORIntIterable>) S
{
   id<ORForall> forall = [[ORForallI alloc] initORForallI:tracker set:S];
   [tracker trackObject: forall];
   return forall;
}
@end;

@implementation ORControl
+(id<ORForall>) forall: (id<ORTracker>) tracker set: (id<ORIntIterable>) S
{
   return [ORFactory forall: tracker set: S];
}
+(void) forall: (id<ORIntIterable>) S suchThat: (ORInt2Bool) suchThat orderedBy: (ORInt2Int) order do: (ORInt2Void) body
{
   ORInt sz = [S size];
   ORInt* value = alloca(sizeof(ORInt)*sz);
   bool* used = alloca(sizeof(bool)*sz);
   memset(used,0,sizeof(bool)*sz);
   id<IntEnumerator> ite = [S enumerator];
   ORInt nb = 0;
   while ([ite more]) {
      value[nb] = [ite next];
      if (!suchThat || suchThat(value[nb]))
         nb++;
   }
   bool done = false;
   while (!done) {
      float best = MAXFLOAT;
      ORInt chosen = -1;
      ORInt i = 0;
      while (i < nb) {
         if (!used[i] && (!suchThat || suchThat(value[i]))) {
            ORInt efi = order? order(value[i]) : i;
            if (efi < best) {
               chosen = i;
               best = efi;
            }
         }
         ++i;
      }
      done = (chosen == -1);
      if (!done) {
         used[chosen] = true;
         body(value[chosen]);
      }
   }
}
@end
