/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORAnnotation.h>
#import <ORFoundation/ORConstraint.h>
#import "ORConstraintI.h"

@interface ORAnnotationCopy : ORAnnotation<ORAnnotation,NSCopying>
{
   id<ORAnnotation> _original;
}
-(id)initWith:(id<ORAnnotation>)src;
-(ORCLevel)levelFor:(id<ORConstraint>)cstr;
@end

@implementation ORAnnotation {
   NSMutableDictionary* _cstr;
   NSMutableDictionary* _classCstr;
   NSMutableDictionary* _generic;
}

-(id) init
{
   self = [super init];
   _classCstr = [[NSMutableDictionary alloc] initWithCapacity:16];
   _cstr = [[NSMutableDictionary alloc] initWithCapacity:16];
   _generic = [[NSMutableDictionary alloc] initWithCapacity:16];
   return self;
}

-(void) dealloc
{
   [_classCstr release];
   [_cstr release];
   [_generic release];
   [super dealloc];
}

- (id) copyWithZone: (NSZone *) zone
{
   return [[ORAnnotationCopy allocWithZone:zone] initWith:self];
}

-(void) addCstr: (id<ORConstraint>) cstr note: (id<ORNote>) n
{
   NSNumber* k = [[NSNumber alloc] initWithInt:[cstr getId]];
   NSMutableArray* na = [_cstr objectForKey: k];
   if (na == nil) {
      na = [[NSMutableArray alloc] initWithCapacity:2];
      [_cstr setObject:na forKey: k];
   }
   [na addObject: n];
   [k release];
}

-(void) addGeneric: (GenericIndex) index note: (id<ORNote>) n
{
    [_generic setObject:n forKey: [[NSNumber alloc] initWithInt: index]];
}

-(void) addClassCstr: (id) ocl note: (id<ORNote>) n
{
   NSMutableArray* na = [_classCstr objectForKey: ocl];
   if (na == nil) {
      na = [[NSMutableArray alloc] initWithCapacity:2];
      [_classCstr setObject:na forKey: ocl];
   }
   [na addObject: n];
}

-(void) transfer: (id<ORConstraint>) o toConstraint: (id<ORConstraint>) d
{
   NSNumber* k = [[NSNumber alloc] initWithInt:[o getId]];
   NSMutableArray* na  = [_cstr objectForKey: k];
   if (na)
      for(id<ORNote> obj in na)
         [self addCstr: d note: obj];
   [k release];
}


-(id<ORConstraint>) noteConstraint: (id<ORConstraint>) cstr consistency: (ORCLevel) cl
{
   id<ORNote> n = [[ORConsistency alloc] initWith:cl];
   [self addCstr: cstr note: n];
   [n release];
   return cstr;
}

-(void) classNoteConstraint: (id) ocl consistency: (ORCLevel) cl
{
   id<ORNote> n = [[ORConsistency alloc] initWith: cl];
   [self addClassCstr: ocl note: n];
   [n release];
}

-(void) genericConstraint: (GenericIndex) index value: (ORInt) value
{
    id<ORNote> n = [[ORValue alloc] initWith: value];
    [self addGeneric: index note: n];
    [n release];
}

-(ORInt) findGeneric: (GenericIndex) index
{
    id<ORNote> genericValue = (id<ORNote>)[_generic objectForKey:[[NSNumber alloc] initWithInt: index]];
    return [(ORValue*)genericValue value];
}

-(id<ORNote>) findConstraintClassNote: (id<ORConstraint>) cstr ofClass: (Class) nc
{
   id cl = [cstr class];
   id<ORNote> rv = nil;
   NSMutableArray* na  = [_classCstr objectForKey: cl];
   if (na) {
      for(id<ORNote> obj in na) {
         if ([obj isKindOfClass:nc]) {
            rv = obj;
            break;
         }
      }
   }
   return rv;
}

-(NSArray*) findConstraintNotes:(id<ORConstraint>) cstr
{
   NSNumber* k = [NSNumber numberWithInt:cstr.getId];
   NSArray*  na = [_cstr objectForKey:k];
   //[k release];
   return na;
}

-(id<ORNote>) findConstraintNote: (id<ORConstraint>) cstr ofClass: (Class) nc
{
   NSNumber* k = [[NSNumber alloc] initWithInt:[cstr getId]];
   id<ORNote> rv = nil;
   NSMutableArray* na  = [_cstr objectForKey: k];
   if (na) {
      for(id<ORNote> obj in na) {
         if ([obj isKindOfClass: nc]) {
            rv = obj;
            break;
         }
      }
   }
   if (rv == nil)
      rv = [self findConstraintClassNote: cstr ofClass: nc];
   [k release];
   return rv;
}

-(ORCLevel) levelFor: (id<ORConstraint>) cstr
{
   ORConsistency* cn = [self findConstraintNote: cstr ofClass: [ORConsistency class]];
   return cn ? [cn level] : Default;
}
-(id<ORConstraint>) cstr: (id<ORConstraint>) cstr consistency: (ORCLevel) cl;
{
   return [self noteConstraint: cstr consistency: cl];
}
-(id<ORConstraint>) hard:(id<ORConstraint>) cstr
{
   return [self noteConstraint:cstr consistency:HardConsistency];
}
-(id<ORConstraint>) dc: (id<ORConstraint>) cstr
{
   return [self noteConstraint: cstr consistency: DomainConsistency];
}
-(id<ORConstraint>) bc: (id<ORConstraint>) cstr
{
   return [self noteConstraint: cstr consistency: RangeConsistency];
}
-(id<ORConstraint>) vc:(id<ORConstraint>) cstr
{
   return [self noteConstraint: cstr consistency: ValueConsistency];
}
-(id<ORConstraint>) relax:(id<ORConstraint>) cstr
{
   return [self noteConstraint: cstr consistency: RelaxedConsistency];
}

-(void) alldifferent: (ORCLevel) cl
{
   return [self classNoteConstraint: [ORAlldifferentI class] consistency: cl];
}

-(void) ddWidth: (ORInt) width
{
    GenericIndex index = DDWidth;
    [self genericConstraint: index value: width];
}
-(void) ddRelaxed: (bool) relaxed
{
    GenericIndex index = DDRelaxed;
    [self genericConstraint: index value: relaxed];
}
-(void) ddWithArcs: (bool) withArcs
{
    GenericIndex index = DDWithArcs;
    [self genericConstraint: index value: withArcs];
}
-(void) ddEqualBuckets: (bool) equalBuckets
{
    GenericIndex index = DDEqualBuckets;
    [self genericConstraint: index value: equalBuckets];
}
-(void) ddUsingSlack: (bool) usingSlack
{
    GenericIndex index = DDUsingSlack;
    [self genericConstraint: index value: usingSlack];
}
-(void) ddRecommendationStyle: (MDDRecommendationStyle) recommendationStyle
{
    GenericIndex index = DDRecommendationStyle;
    [self genericConstraint: index value: recommendationStyle];
}
-(void) ddVariableOverlap:(ORInt)composition
{
    GenericIndex index = DDComposition;
    [self genericConstraint: index value: composition];
}
-(void) ddSplitAllLayersBeforeFiltering:(bool)splitAllLayersBeforeFiltering
{
    GenericIndex index = DDSplitAllLayersBeforeFiltering;
    [self genericConstraint:index value:splitAllLayersBeforeFiltering];
}
-(void) ddMaxSplitIter:(int)maxSplitIter
{
    GenericIndex index = DDMaxSplitIter;
    [self genericConstraint:index value:maxSplitIter];
}
-(void) ddMaxRebootDistance:(int)maxRebootDistance
{
    GenericIndex index = DDMaxRebootDistance;
    [self genericConstraint:index value:maxRebootDistance];
}
-(void) ddUseStateExistence:(bool)useStateExistence
{
    GenericIndex index = DDUseStateExistence;
    [self genericConstraint:index value:useStateExistence];
}
-(void) ddNumNodesSplitAtATime:(int)numNodesSplitAtATime
{
    GenericIndex index = DDNumNodesSplitAtATime;
    [self genericConstraint:index value:numNodesSplitAtATime];
}
-(void) ddNumNodesDefinedAsPercent:(bool)numNodesDefinedAsPercent
{
    GenericIndex index = DDNumNodesDefinedAsPercent;
    [self genericConstraint:index value:numNodesDefinedAsPercent];
}
-(void) ddSplittingStyle:(int)splittingStyle
{
    GenericIndex index = DDSplittingStyle;
    [self genericConstraint:index value:splittingStyle];
}

-(NSString*) description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   [buf appendString:@"{"];
   @autoreleasepool {
      [_cstr enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
         [buf appendString:[key description]];
         [buf appendString:@" : "];
         [buf appendString:[obj description]];
         [buf appendString:@","];
      }];
   }
   [buf appendString:@"}"];
   return buf;
}
@end

@implementation ORConsistency
-(id)init
{
   self = [super init];
   _cLevel = Default;
   return self;
}
-(id)initWith: (ORCLevel)cl
{
   self = [super init];
   _cLevel = cl;
   return self;
}
- (id) copyWithZone: (NSZone *) zone
{
   return [[ORConsistency allocWithZone:zone] initWith: _cLevel];
}
-(ORCLevel) level
{
   return _cLevel;
}
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   static const char* names[] = {"dom","rng","val","relax","hard","soft","def"};
   [buf appendFormat:@"c=%s",names[_cLevel]];
   return buf;
}
@end

@implementation ORValue
-(id)init
{
    self = [super init];
    _value = 0;
    return self;
}
-(id)initWith: (ORInt)value
{
    self = [super init];
    _value = value;
    return self;
}
- (id) copyWithZone: (NSZone *) zone
{
    return [[ORValue allocWithZone:zone] initWith: _value];
}
-(ORInt) value
{
    return _value;
}
-(NSString*)description
{
    return [NSString stringWithFormat:@"%d", _value];
}
@end

@implementation ORAnnotationCopy
-(id)initWith: (id<ORAnnotation>) src
{
   self = [super init];
   _original = [src retain];
   return self;
}
-(void) dealloc
{
   [_original release];
   [super dealloc];
}
- (id) copyWithZone:(NSZone *)zone
{
   return [[ORAnnotationCopy allocWithZone: zone] initWith:self];
}
-(ORCLevel) levelFor: (id<ORConstraint>) cstr
{
   ORConsistency* cn = [super findConstraintNote:cstr ofClass:[ORConsistency class]];
   if (cn)
      return [cn level];
   else
      return [_original levelFor:cstr];
}
-(ORInt) findGeneric:(GenericIndex) index {
    return [_original findGeneric:index];
}
-(void) transfer: (id<ORConstraint>) src toConstraint: (id<ORConstraint>) d
{
   NSArray* allNotes = src ? [_original findConstraintNotes:src] : nil;
   if (allNotes) {
      for(id<ORNote> oneNote in allNotes) {
         [self addCstr:d note:oneNote];
      }
   }
}
-(NSString*) description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   @autoreleasepool {
      [buf appendString:[super description]];
      [buf appendString:@"src:"];
      [buf appendString:[_original description]];
   }
   return buf;
}
@end


