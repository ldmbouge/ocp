/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORTracker.h>
#import <ORFoundation/ORFactory.h>
#import <ORFoundation/ORControl.h>
#import <ORFoundation/ORVar.h>

#import <math.h>
#if defined(__linux__)
#import <values.h>
#endif


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
   //NSLog(@"Dealloc  ORForallI (%p)",self);
   [_S release];
   [_arraySuchThat release];
   [_arrayOrderedBy release];
   [super dealloc];
}
-(id<ORForall>) suchThat: (ORInt2Bool) suchThat
{
   [_arraySuchThat addObject: [suchThat copy]];
   return self;
}
-(id<ORForall>) orderedBy: (ORInt2Int) orderedBy
{
   [_arrayOrderedBy addObject: [orderedBy copy]];
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
   bool* used = alloca(sizeof(ORBool)*sz);
   memset(used,0,sizeof(ORBool)*sz);
   ORInt nbo = (ORInt) [_arrayOrderedBy count];
   float* best = alloca(sizeof(float)*nbo);
   __block ORInt nb = 0;
   [_S enumerateWithBlock:^(ORInt k) {
      value[nb] = k;
      if (testSuchThat(value[nb],_arraySuchThat))
         nb++;
   }];
   bool done = false;
   while (!done) {
      for(int k = 0; k < nbo; k++)
         best[k] = MAXDBL;
      ORInt chosen = -1;
      ORInt i = 0;
      while (i < nb) {
         if (!used[i]) {
            BOOL valid = true;
            for(ORInt2Bool fun in _arraySuchThat) {
               valid = fun(value[i]);
               if (!valid) break;
            }
            if (valid) {
               if (isSmaller(value[i],_arrayOrderedBy,best)) {
                  chosen = i;
                  ORInt k = 0;
                  for(ORInt2Int fun in _arrayOrderedBy)
                     best[k++] = fun(value[i]);
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
   [tracker trackMutable: forall];
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
   ORInt sz = S.size;
   ORInt value[sz];
   ORBool used[sz];
   memset(used,0,sizeof(ORBool)*sz);
   ORInt nb = 0;
   id<IntEnumerator> it = S.enumerator;
   while (it.more) {
      value[nb] = it.next;
      if (!suchThat || suchThat(value[nb]))
         nb++;
   }
   [it release];
   assert(nb <= sz);
   ORBool done = NO;
   while (!done) {
      ORDouble best = MAXDBL;
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
 	 assert(chosen >=0 && chosen <= sz);
         used[chosen] = true;
         body(value[chosen]);
      }
   }
}
@end
