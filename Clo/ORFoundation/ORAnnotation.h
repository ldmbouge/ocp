/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
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
   Default
} ORCLevel;

@protocol ORAnnotation <NSObject>
-(id<ORConstraint>)dc:(id<ORConstraint>)cstr;
-(id<ORConstraint>)bc:(id<ORConstraint>)cstr;
-(id<ORConstraint>)vc:(id<ORConstraint>)cstr;
-(ORCLevel)levelFor:(id<ORConstraint>)cstr;
@end

@interface ORAnnotation : ORObject<ORAnnotation>
-(id<ORConstraint>)dc:(id<ORConstraint>)cstr;
-(id<ORConstraint>)bc:(id<ORConstraint>)cstr;
-(id<ORConstraint>)vc:(id<ORConstraint>)cstr;
-(ORCLevel)levelFor:(id<ORConstraint>)cstr;
@end

@protocol ORNote <NSObject>
@end

@interface ORConsistency : NSObject<ORNote> {
   ORCLevel _cLevel;
}
-(id)init;
-(id)initWith:(ORCLevel)cl;
-(ORCLevel)level;
@end