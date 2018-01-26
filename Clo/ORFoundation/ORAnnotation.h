/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORObject.h>

typedef enum {
   DomainConsistency,
   RangeConsistency,
   ValueConsistency,
   RelaxedConsistency,
   HardConsistency,
   SoftConsistency,
   Default
} ORCLevel;

@protocol ORAnnotation <NSObject,NSCopying>
-(ORCLevel) levelFor:(id<ORConstraint>)cstr;
-(ORDouble) kbpercent;
-(id)copy;

-(ORBool) hasFilteringPercent;
-(void) kbpercent:(ORDouble) p;
-(id<ORConstraint>) dc: (id<ORConstraint>) cstr;
-(id<ORConstraint>) bc: (id<ORConstraint>) cstr;
-(id<ORConstraint>) vc: (id<ORConstraint>) cstr;
-(id<ORConstraint>) relax: (id<ORConstraint>) cstr;
-(id<ORConstraint>) cstr: (id<ORConstraint>) cstr consistency: (ORCLevel) cl;
-(id<ORConstraint>) hard:(id<ORConstraint>) cstr;
-(void) alldifferent: (ORCLevel) cl;

-(NSArray*) findConstraintNotes:(id<ORConstraint>) cstr;
-(void) transfer: (id<ORConstraint>) o toConstraint: (id<ORConstraint>) o;
@end

@interface ORAnnotation : ORObject<ORAnnotation,NSCopying>
@end

@protocol ORNote <NSObject,NSCopying>
@end

@interface ORConsistency : NSObject<ORNote> {
   ORCLevel _cLevel;
}
-(id)init;
-(id)initWith:(ORCLevel)cl;
-(ORCLevel)level;
@end

