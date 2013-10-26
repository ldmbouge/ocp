/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORAnnotation.h"
#import "ORConstraint.h"

@interface ORAnnotationCopy : ORAnnotation<ORAnnotation,NSCopying>
{
   id<ORAnnotation> _original;
}
-(id)initWith:(id<ORAnnotation>)src;
-(ORCLevel)levelFor:(id<ORConstraint>)cstr;
@end

@implementation ORAnnotation {
   NSMutableDictionary* _notes;
}
-(id)init
{
   self = [super init];
   _notes = [[NSMutableDictionary alloc] initWithCapacity:16];
   return self;
}
-(void)dealloc
{
   [_notes release];
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[ORAnnotationCopy allocWithZone:zone] initWith:self];
}

-(id<ORConstraint>)note:(id<ORConstraint>)cstr consistency:(ORCLevel)cl
{
   NSNumber* k = [[NSNumber alloc] initWithInt:[cstr getId]];
   id<ORNote> n = [[ORConsistency alloc] initWith:cl];
   id xn = [_notes objectForKey:k];
   if (xn == nil) {
      [_notes setObject:n forKey:k];
   } else {
      if ([xn isKindOfClass:[NSMutableArray class]]) {
         NSMutableArray* na = xn;
         [na addObject:n];
      } else {
         NSMutableArray* na = [[NSMutableArray alloc] initWithCapacity:2];
         [_notes setObject:na forKey:k];
         [na addObject:n];
      }
   }
   [n release];
   [k release];
   return cstr;
}

-(id<ORConstraint>)dc:(id<ORConstraint>)cstr
{
   return [self note:cstr consistency:DomainConsistency];
}
-(id<ORConstraint>)bc:(id<ORConstraint>)cstr
{
   return [self note:cstr consistency:RangeConsistency];
}
-(id<ORConstraint>)vc:(id<ORConstraint>)cstr
{
   return [self note:cstr consistency:ValueConsistency];
}
-(id<ORNote>)findNote:(id<ORConstraint>)cstr ofClass:(Class)nc
{
   NSNumber* k = [[NSNumber alloc] initWithInt:[cstr getId]];
   id<ORNote> rv = nil;
   id xn = [_notes objectForKey:k];
   if (xn && [xn isKindOfClass:nc])
      rv = xn;
   else if (xn && [xn isKindOfClass:[NSMutableArray class]]) {
      NSMutableArray* na = xn;
      for(id<ORNote> obj in na) {
         if ([obj isKindOfClass:nc]) {
            rv = obj;
            break;
         }
      }
   }
   [k release];
   return rv;
}
-(ORCLevel)levelFor:(id<ORConstraint>)cstr
{
   ORConsistency* cn = [self findNote:cstr ofClass:[ORConsistency class]];
   return cn ? [cn level] : Default;
}
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   [buf appendString:@"{"];
   @autoreleasepool {
      [_notes enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
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
-(ORCLevel)level
{
   return _cLevel;
}
-(NSString*)description
{
   NSMutableString* buf = [[NSMutableString alloc] initWithCapacity:64];
   static const char* names[] = {"dom","rng","val","def"};
   [buf appendFormat:@"c=%s",names[_cLevel]];
   return buf;
}
@end

@implementation ORAnnotationCopy
-(id)initWith:(id<ORAnnotation>)src
{
   self = [super init];
   _original = [src retain];
   return self;
}
-(void)dealloc
{
   [_original release];
   [super dealloc];
}
- (id)copyWithZone:(NSZone *)zone
{
   return [[ORAnnotationCopy alloc] initWith:self];
}
-(ORCLevel)levelFor:(id<ORConstraint>)cstr
{
   ORConsistency* cn = [super findNote:cstr ofClass:[ORConsistency class]];
   if (cn)
      return cn ? [cn level] : Default;
   else
      return [_original levelFor:cstr];
}
-(NSString*)description
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