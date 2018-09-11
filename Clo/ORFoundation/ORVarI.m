/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import "ORVarI.h"
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORFactory.h>

@implementation ORIntVarI {
@protected
   id<ORTracker>  _tracker;
   id<ORIntRange> _domain;
   NSString* _prettyname;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain
{
   self = [super init];
   _tracker = [track tracker];
   _domain = domain;
   _ba[0] = YES; // dense
   _ba[1] = ([domain low] == 0 && [domain up] == 1); // isBool
   [track trackVariable: self];
   return self;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track domain: (id<ORIntRange>) domain name:(NSString*) name
{
   self = [self initORIntVarI: track domain:domain];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORIntVarI*) initORIntVarI: (id<ORTracker>) track bounds: (id<ORIntRange>) domain
{
   self = [super init];
   _tracker = [track tracker];
   _domain = domain;
   _ba[0] = false; // dense
   _ba[1] = ([domain low] == 0 && [domain up] == 1); // isBool
   [track trackVariable: self];
   return self;
}
-(void) dealloc
{
   //NSLog(@"ORIntVarI(%p)::dealloc %d\n",self,_name);
   [super dealloc];
   if(_prettyname != nil)
      [_prettyname release];
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_ba[0]];
   [aCoder encodeValueOfObjCType:@encode(ORBool) at:&_ba[1]];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_ba[0]];
   [aDecoder decodeValueOfObjCType:@encode(ORBool) at:&_ba[1]];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}

-(ORBool) isVariable
{
   return YES;
}
-(enum ORVType) vtype
{
   if (_domain.low == 0 && _domain.up == 1)
      return ORTBool;
   else
      return ORTInt;
}
-(NSString*) description
{
   if(_prettyname != nil)
      return [NSString stringWithFormat:@"%@:%03d(%@,%c)",_prettyname,_name,[_domain description],_ba[0] ? 'D':'S'];
   return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c)",_name,[_domain description],_ba[0] ? 'D':'S'];
}
-(ORInt) value
{
   return [self intValue];
}
-(ORInt) min
{
   return [_domain low];
}
-(ORInt) max
{
   return [_domain up];
}
-(ORInt) low
{
   return [_domain low];
}
-(ORInt) up
{
   return [_domain up];
}
-(ORBool) isBool
{
   return _ba[1]; // isBool
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(id<ORIntRange>) domain
{
   return _domain;
}
-(ORBool) hasDenseDomain
{
   return _ba[0]; // dense
}
-(ORInt)scale
{
   return 1;
}
-(ORInt)shift
{
   return 0;
}
-(ORInt)literal
{
   return 0;
}
-(id<ORIntVar>)base
{
   return self;
}
-(void) visit: (ORVisitor*) v
{
   [v visitIntVar: self];
}
-(NSString*) prettyname
{
   return _prettyname;
}
@end

@implementation ORIntVarAffineI {
   ORInt        _a;
   id<ORIntVar> _x;
   ORInt        _b;
}
-(ORIntVarAffineI*)initORIntVarAffineI:(id<ORTracker>)tracker var:(id<ORIntVar>)x scale:(ORInt)a shift:(ORInt)b
{
   id<ORIntRange> xr = [x domain];
   id<ORIntRange> ar;
   if (a > 0)
      ar = [ORFactory intRange:tracker low:a * [xr low] + b up:a * [xr up] + b];
   else
      ar = [ORFactory intRange:tracker low:a * [xr up] + b up:a * [xr low] + b];
   self = [super initORIntVarI:tracker domain:ar];
   _a = a;
   _x = x;
   _b = b;
   return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_a];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_b];
   [aCoder encodeObject:_x];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_a];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_b];
   _x = [aDecoder decodeObject];
   return self;
}
-(NSString*) description
{
   char d = _ba[0] ? 'D':'S';
   return [NSString stringWithFormat:@"var<OR>{int}:%03d(%@,%c,(%d * %@ + %d)",_name,[_domain description],d,_a,_x,_b];
}
-(ORInt)scale
{
   return _a;
}
-(ORInt)shift
{
   return _b;
}
-(id<ORIntVar>)base
{
   return _x;
}
-(void) visit: (ORVisitor*) v
{
   [v visitAffineVar: self];
}
@end

@implementation ORIntVarLitEQView {
   id<ORIntVar>   _x;
   ORInt        _lit;
}
-(ORIntVarLitEQView*)initORIntVarLitEQView:(id<ORTracker>)tracker var:(id<ORIntVar>)x eqi:(ORInt)lit
{
   self = [super initORIntVarI:tracker domain:RANGE(tracker,0,1)];
   _x = x;
   _lit = lit;
   return self;
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_lit];
   [aCoder encodeObject:_x];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_lit];
   _x = [aDecoder decodeObject];
   return self;
}
-(ORInt)literal
{
   return _lit;
}
-(id<ORIntVar>)base
{
   return _x;
}
-(void) visit: (ORVisitor*)v
{
   [v visitIntVarLitEQView:self];
}
@end

@implementation ORRealVarI
{
@protected
   id<ORTracker>    _tracker;
   id<ORRealRange> _domain;
   BOOL             _hasBounds;
}
-(ORRealVarI*) init: (id<ORTracker>) track low: (ORDouble) low up: (ORDouble) up
{
   self = [super init];
   _tracker = track;
   _domain = [ORFactory realRange:track low:low up:up];
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORRealVarI*) init: (id<ORTracker>) track up: (ORDouble) up
{
   self = [super init];
   _tracker = track;
   _domain = [ORFactory realRange:track low:0 up:up];
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORRealVarI*) init: (id<ORTracker>) track
{
   self = [super init];
   _tracker = track;
   _hasBounds = false;
   [track trackVariable: self];
   return self;
}
-(void)setDomain:(id<ORRealRange>)domain
{
   _domain = domain;
}
-(id<ORRealRange>) domain
{
   assert(_domain != NULL);
   return _domain;
}
-(void) dealloc
{
   [super dealloc];
}
-(enum ORVType) vtype
{
   return ORTReal;
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if (_domain.low <= - FLT_MAX && _domain.up >= FLT_MAX)
      return [NSString stringWithFormat:@"var<OR>{real}:%03d(-inf,+inf)",_name];
   else if (_domain.low <= - FLT_MAX)
      return [NSString stringWithFormat:@"var<OR>{real}:%03d(-inf,%f)",_name,_domain.up];
   else if (_domain.up >= FLT_MAX)
      return [NSString stringWithFormat:@"var<OR>{real}:%03d(%f,+inf)",_name,_domain.low];
   else
      return [NSString stringWithFormat:@"var<OR>{real}:%03d(%f,%f)",_name,_domain.low,_domain.up];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORDouble) low
{
   return _domain.low;
}
-(ORDouble) up
{
   return _domain.up;
}
@end

//-------------------------
@implementation ORFloatVarI
{
@protected
   id<ORTracker>    _tracker;
   id<ORFloatRange> _domain;
   id<ORRationalRange> _domainError;
   BOOL             _hasBounds;
   NSString*         _prettyname;
}
-(ORFloatVarI*) init: (id<ORTracker>) track domain:(id<ORFloatRange>)dom
{
   self = [super init];
   _tracker = track;
   _domain = dom;
   if(_domain.low == _domain.up){
      ORRational* zero = [ORRational rationalWith_d:0.0f];
      _domainError = [ORFactory rationalRange:track low:zero up:zero];
      [zero release];
   } else {
      ORRational* low = [ORRational rationalWith_d:-INFINITY];
      ORRational* up = [ORRational rationalWith_d:+INFINITY];
      _domainError = [ORFactory rationalRange:track low:low up:up];
      [low release];
      [up release];
   }
   _hasBounds = ([dom low] != -INFINITY || [dom up] != INFINITY);
   [track trackVariable: self];
   return self;
}
-(ORFloatVarI*) init: (id<ORTracker>) track domain:(id<ORFloatRange>)dom domainError:(id<ORRationalRange>)domError
{
   self = [super init];
   _tracker = track;
   _domain = dom;
   _domainError = domError;
   _hasBounds = ([dom low] != -INFINITY || [dom up] != INFINITY);
   [track trackVariable: self];
   return self;
}
-(ORFloatVarI*) init: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up
{
   return  [self init:track domain:[ORFactory floatRange:track low:low up:up]];
}
-(ORFloatVarI*) init: (id<ORTracker>) track up: (ORFloat) up
{
   return [self init:track low:0.f up:up];
}
-(ORFloatVarI*) init: (id<ORTracker>) track
{
   return [self init:track domain:[ORFactory floatRange:track]];
}
-(ORFloatVarI*) init: (id<ORTracker>) track name:(NSString*) name
{
   self = [self init:track];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORFloatVarI*) init: (id<ORTracker>) track up: (ORFloat) up name:(NSString*) name
{
   self = [self init:track low:0.f up:up name:name];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORFloatVarI*) init: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up name:(NSString*) name
{
   self = [self init:track domain:[ORFactory floatRange:track low:low up:up]];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORFloatVarI*) init: (id<ORTracker>) track low: (ORFloat) low up: (ORFloat) up elow: (ORRational*) elow eup: (ORRational*) eup name:(NSString*) name
{
   self = [self init:track domain:[ORFactory floatRange:track low:low up:up] domainError:[ORFactory rationalRange:track low:elow up:eup]];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(id<ORFloatRange>) domain
{
   assert(_domain != NULL);
   return _domain;
}
-(id<ORRationalRange>) domainError
{
   assert(_domainError != NULL);
   return _domainError;
}
-(void) dealloc
{
   if(_prettyname != nil)
      [_prettyname release];
   [super dealloc];
}
-(enum ORVType) vtype
{
   return ORTFloat;
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeObject:_prettyname];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   _prettyname = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if(_prettyname != nil)
      return [NSString stringWithFormat:@"%@:%03d(%f,%f)±(%@,%@)",_prettyname,_name,_domain.low,_domain.up,_domainError.low,_domainError.up];
   return [NSString stringWithFormat:@"var<OR>{float}:%03d(%f,%f)±(%@,%@)",_name,_domain.low,_domain.up,_domainError.low,_domainError.up];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (ORVisitor*) v
{
   [v visitFloatVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORFloat) low
{
   return _domain.low;
}
-(ORFloat) up
{
   return _domain.up;
}
-(ORRational*) elow
{
   return _domainError.low;
}
-(ORRational*) eup
{
   return _domainError.up;
}
-(ORFloat) fmin
{
   return [_domain low];
}
-(ORFloat) fmax
{
   return [_domain up];
}
-(ORRational*) qmin
{
   return [_domainError low];
}
-(ORRational*) qmax
{
   return [_domainError up];
}
-(NSString*) prettyname
{
   return _prettyname;
}
@end

//-------------------------
@implementation ORRationalVarI
{
@protected
   id<ORTracker>        _tracker;
   id<ORRationalRange>  _domain;
   BOOL                 _hasBounds;
   NSString*            _prettyname;
}
-(ORRationalVarI*) init: (id<ORTracker>) track domain:(id<ORRationalRange>)dom
{
   self = [super init];
   _tracker = track;
   _domain = dom;
   ORRational* ninf = [ORRational rationalWith_d:-INFINITY];
   ORRational* pinf = [ORRational rationalWith_d:+INFINITY];
   _hasBounds = ([[dom low] neq: ninf] || [[dom up] neq: pinf]);
   [track trackVariable: self];
   return self;
}
-(ORRationalVarI*) init: (id<ORTracker>) track low: (ORRational*) low up: (ORRational*) up
{
   return  [self init:track domain:[ORFactory rationalRange:track low:low up:up]];
}
-(ORRationalVarI*) init: (id<ORTracker>) track up: (ORRational*) up
{
   ORRational* zero = [ORRational rationalWith_d:0.0];
   ORRationalVarI* r = [self init:track low:zero up:up];
   return r;
}
-(ORRationalVarI*) init: (id<ORTracker>) track
{
   return [self init:track domain:[ORFactory rationalRange:track]];
}
-(ORRationalVarI*) init: (id<ORTracker>) track name:(NSString*) name
{
   self = [self init:track];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORRationalVarI*) init: (id<ORTracker>) track up: (ORRational*) up name:(NSString*) name
{
   ORRational* zero = [ORRational rationalWith_d:0.0];
   self = [self init:track low:zero up:up name:name];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORRationalVarI*) init: (id<ORTracker>) track low: (ORRational*) low up: (ORRational*) up name:(NSString*) name
{
   self = [self init:track domain:[ORFactory rationalRange:track low:low up:up]];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(id<ORRationalRange>) domain
{
   assert(_domain != NULL);
   return _domain;
}
-(void) dealloc
{
   if(_prettyname != nil)
      [_prettyname release];
   [super dealloc];
}
-(enum ORVType) vtype
{
   return ORTRational;
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeObject:_prettyname];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   _prettyname = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if(_prettyname != nil)
      return [NSString stringWithFormat:@"%@:%03d(%@,%@)",_prettyname,_name,_domain.low,_domain.up];
   return [NSString stringWithFormat:@"var<OR>{rational}:%03d(%@,%@)",_name,_domain.low,_domain.up];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRationalVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORRational*) low
{
   return _domain.low;
}
-(ORRational*) up
{
   return _domain.up;
}
-(ORRational*) qmin
{
   return [_domain low];
}
-(ORRational*) qmax
{
   return [_domain up];
}
-(NSString*) prettyname
{
   return _prettyname;
}
@end

@implementation ORDoubleVarI
{
@protected
   id<ORTracker>    _tracker;
   id<ORDoubleRange> _domain;
   id<ORRationalRange> _domainError;
   BOOL             _hasBounds;
   NSString*         _prettyname;
}
-(ORDoubleVarI*) init: (id<ORTracker>) track low: (ORDouble) low up: (ORDouble) up
{
   return [self init:track domain:[ORFactory doubleRange:track low:low up:up] name:nil];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track up: (ORDouble) up
{
   return [self init:track low:-INFINITY up:+INFINITY];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track
{
   return [self init:track low:-INFINITY up:+INFINITY];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track domain:(id<ORDoubleRange>)dom
{
   return [self init:track domain:dom name:nil];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track domain:(id<ORDoubleRange>)dom name:(NSString *)name
{
   self = [super init];
   _tracker = track;
   _domain = dom;
   _hasBounds = ([dom low] != -INFINITY || [dom up] != INFINITY);
   if(_domain.low == _domain.up){
      ORRational* zero = [ORRational rationalWith_d:0.0f];
      _domainError = [ORFactory rationalRange:track low:zero up:zero];
      [zero release];
   } else {
      ORRational* low = [ORRational rationalWith_d:-INFINITY];
      ORRational* up = [ORRational rationalWith_d:+INFINITY];
      _domainError = [ORFactory rationalRange:track low:low up:up];
      [low release];
      [up release];
   }
   _prettyname = name;
   [track trackVariable: self];
   return self;
}
-(ORDoubleVarI*) init: (id<ORTracker>) track domain:(id<ORDoubleRange>)dom domainError:(id<ORRationalRange>)domError
{
   self = [super init];
   _tracker = track;
   _domain = dom;
   _domainError = domError;
   _hasBounds = ([dom low] != -INFINITY || [dom up] != INFINITY);
   [track trackVariable: self];
   return self;
}
-(ORDoubleVarI*) init: (id<ORTracker>) track low: (ORDouble) low up: (ORDouble) up name:(NSString *)name
{
   return [self init:track domain:[ORFactory doubleRange:track low:low up:up] name:name];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track up: (ORDouble) up name:(NSString *)name
{
   return [self init:track low:-INFINITY up:+INFINITY name:name];
}
-(ORDoubleVarI*) init: (id<ORTracker>) track low: (ORDouble) low up: (ORDouble) up elow: (ORRational*) elow eup: (ORRational*) eup name:(NSString*) name
{
   self = [self init:track domain:[ORFactory doubleRange:track low:low up:up] domainError:[ORFactory rationalRange:track low:elow up:eup]];
   _prettyname = [[NSString alloc] initWithString:name];
   return self;
}
-(ORDoubleVarI*) init: (id<ORTracker>) track name:(NSString *)name
{
   return [self init:track low:-INFINITY up:+INFINITY name:name];
}
-(id<ORDoubleRange>) domain
{
   assert(_domain != NULL);
   return _domain;
}
-(id<ORRationalRange>) domainError
{
   assert(_domainError != NULL);
   return _domainError;
}
-(void) dealloc
{
   if(_prettyname != nil)
      [_prettyname release];
   [super dealloc];
}
-(enum ORVType) vtype
{
   return ORTDouble;
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeObject:_prettyname];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   _prettyname = [[aDecoder decodeObject] retain];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   if(_prettyname != nil)
      return [NSString stringWithFormat:@"%@:%03d(%lf,%lf)±(%@,%@)",_prettyname,_name,_domain.low,_domain.up,_domainError.low,_domainError.up];
   else
      return [NSString stringWithFormat:@"var<OR>{double}:%03d(%lf,%lf)",_name,_domain.low,_domain.up];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (ORVisitor*) v
{
   [v visitDoubleVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORDouble) low
{
   return _domain.low;
}
-(ORDouble) up
{
   return _domain.up;
}
-(ORRational*) elow
{
   return _domainError.low;
}
-(ORRational*) eup
{
   return _domainError.up;
}
-(ORDouble) dmin
{
   return [_domain low];
}
-(ORDouble) dmax
{
   return [_domain up];
}
-(NSString*) prettyname
{
   return _prettyname;
}
@end

@implementation ORLDoubleVarI
{
@protected
   id<ORTracker>    _tracker;
   id<ORLDoubleRange> _domain;
   BOOL             _hasBounds;
}
-(ORLDoubleVarI*) init: (id<ORTracker>) track low: (ORLDouble) low up: (ORLDouble) up
{
   self = [super init];
   _tracker = track;
   _domain = [ORFactory ldoubleRange:track low:low up:up];
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORLDoubleVarI*) init: (id<ORTracker>) track up: (ORLDouble) up
{
   self = [super init];
   _tracker = track;
   _domain = [ORFactory ldoubleRange:track low:0 up:up];
   _hasBounds = true;
   [track trackVariable: self];
   return self;
}
-(ORLDoubleVarI*) init: (id<ORTracker>) track
{
   self = [super init];
   _tracker = track;
   _hasBounds = false;
   [track trackVariable: self];
   return self;
}
-(ORLDoubleVarI*) init: (id<ORTracker>) track domain:(id<ORLDoubleRange>)dom
{
   self = [super init];
   _tracker = track;
   _hasBounds = false;
   _domain = dom;
   [track trackVariable: self];
   return self;
}
-(id<ORLDoubleRange>) domain
{
   assert(_domain != NULL);
   return _domain;
}
-(void) dealloc
{
   [super dealloc];
}
-(enum ORVType) vtype
{
   return ORTLDouble;
}
-(void) encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeObject:_domain];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
}
-(id) initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   _domain  = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   return self;
}
-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"var<OR>{ldouble}:%03d(%LF,%LF)",_name,_domain.low,_domain.up];
}
-(id<ORTracker>) tracker
{
   return _tracker;
}
-(void) visit: (ORVisitor*) v
{
   [v visitLDoubleVar: self];
}
-(ORBool) hasBounds
{
   return _hasBounds;
}
-(ORLDouble) low
{
   return _domain.low;
}
-(ORLDouble) up
{
   return _domain.up;
}
@end
//-------------------------

@implementation ORBitVarI {
   id<ORTracker>    _tracker;
   ORUInt*          _low;
   ORUInt*          _up;
   ORUInt           _bLen;
   ORUInt           _nb;
   
}
-(ORBitVarI*)initORBitVarI:(id<ORTracker>)tracker low:(ORUInt*)low up:(ORUInt*)up bitLength:(ORInt)len
{
   self = [super init];
   _bLen = len;
   _nb = (_bLen / 32) + ((_bLen % 32) ? 1 : 0);
   _low = malloc(sizeof(ORUInt)*_nb);
   _up = malloc(sizeof(ORUInt)*_nb);
   memcpy(_low,low,sizeof(ORUInt)*_nb);
   memcpy(_up,up,sizeof(ORUInt)*_nb);
   _tracker = tracker;
   [tracker trackVariable: self];
   return self;
}
-(void)dealloc
{
   free(_low);
   free(_up);
   [super dealloc];
}
-(ORUInt*)low
{
   return _low;
}
-(ORUInt*)up
{
   return _up;
}
//-(ORULong) maxRank
//{
//   if (_impl)
//      return [[_impl dereference] maxRank];
//   else
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//}
//-(ORULong) getRank:(ORUInt*)v
//{
//   if (_impl)
//      return [[_impl dereference] getRank:v];
//   else
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//}
//-(ORUInt*) atRank:(ORULong)r
//{
//   if (_impl)
//      return [[_impl dereference] atRank:r];
//   else
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//}

-(ORUInt)bitLength
{
   return _bLen;
}

//-(BOOL) bound
//{
//   if (_impl)
//      return [[_impl dereference] bound];
//   else
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//}
//-(ORBounds) bounds
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] bounds];
//   else
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//}
//-(uint64)min
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] min];
//   else {
//      return (long long)_low[1]<<32 | _low[0];
//   }
//}
//-(uint64)max
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] min];
//   else {
//      return (long long)_low[1]<<32 | _low[0];
//   }
//}
//-(ORInt)  domsize
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] domsize];
//   else {
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//   }
//}
//-(ORUInt)  lsFreeBit
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] lsFreeBit];
//   else {
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//   }
//}
//-(ORUInt)  msFreeBit
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] msFreeBit];
//   else {
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//   }
//}
//
//-(ORULong)  numPatterns
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] numPatterns];
//   else {
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//   }
//}
//
//-(ORStatus) bind:(unsigned int *)val
//{
//   return [_impl bind:val];
//}
//-(bool) member: (unsigned int*) v
//{
//   if (_impl)
//      return [(id<ORBitVar>)[_impl dereference] member:v];
//   else {
//      @throw [[ORExecutionError alloc] initORExecutionError:"The variable has no concretization"];
//   }
//}
//-(bool) isFree:(ORUInt)pos
//{
//   return [(id<ORBitVar>)[_impl dereference] isFree:pos];
//}



-(enum ORVType) vtype
{
   return ORTBit;
}

-(void) visit: (ORVisitor*)v
{
   [v visitBitVar:self];
}

-(id<ORTracker>) tracker
{
   return _tracker;
}

-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_tracker];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_bLen];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_nb];
   [aCoder encodeValueOfObjCType:@encode(ORUInt) at:&_name];
   [aCoder encodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_low];
   [aCoder encodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_up];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _tracker = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_bLen];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_nb];
   [aDecoder decodeValueOfObjCType:@encode(ORUInt) at:&_name];
   _low = malloc(sizeof(ORUInt)*_nb);
   _up = malloc(sizeof(ORUInt)*_nb);
   [aDecoder decodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_low];
   [aDecoder decodeArrayOfObjCType:@encode(ORUInt) count:_nb at:_up];
   return self;
}

-(ORBool) isVariable
{
   return YES;
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"bitvar<OR>{int}:%03d",_name];
}
-(NSString*)stringValue
{
   return [self description];
}
@end


@implementation ORVarLitterals
{
   id<ORIntVar>* _array;
   ORInt _low;
   ORInt _up;
   ORInt _nb;
}
-(ORVarLitterals*) initORVarLitterals: (id<ORTracker>) tracker var: (id<ORIntVar>) var
{
   self = [super init];
   _low = [var low];
   _up = [var up];
   _nb = _up - _low + 1;
   _array = malloc(_nb * sizeof(id<ORIntVar>));
   _array -= _low;
   id<ORIntRange> R01 = [ORFactory intRange: tracker low: 0 up: 1];
   for(ORInt i = _low; i <= _up; i++)
      _array[i] = [ORFactory intVar:tracker domain:R01];
   return self;
}
-(void) dealloc
{
   _array += _low;
   free(_array);
   [super dealloc];
}
-(ORInt) low
{
   return _low;
}
-(ORInt) up
{
   return _up;
}
-(id<ORIntVar>) litteral: (ORInt) i
{
   if (i >= _low && i <= _up)
      return _array[i];
   return NULL;
}
-(BOOL) exist: (ORInt) i
{
   return (i >= _low && i <= _up);
}
-(NSString*) description
{
   NSMutableString* rv = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [rv appendFormat:@"VarLitterals(%d,%d) [\n",_low,_up];
   for(ORInt i = _low; i <= _up; i++)
      [rv appendFormat:@"\t%@\n",[_array[i] description]];
   [rv appendFormat:@"] \n"];
   return rv;
}
@end


@implementation ORDisabledFloatVarArrayI{
   id<ORVarArray>          _vars;
   id<ORTrailableIntArray>      _disabled;
}
-(id<ORDisabledFloatVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine
{
   self = [super init];
   _vars = vars;
   _disabled = [ORFactory trailableIntArray:engine range:[vars range] value:0];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORVar>) at: (ORInt) value
{
   return [_vars at:value];
}
-(void) set: (id<ORVar>) x at: (ORInt) value
{
   [_vars set:x at:value];
}
-(id<ORVar>) objectAtIndexedSubscript: (NSUInteger) key
{
   return [_vars objectAtIndexedSubscript:key];
}
-(void) setObject: (id<ORFloatVar>) newValue atIndexedSubscript: (NSUInteger) idx
{
   [_vars setObject:newValue atIndexedSubscript:idx];
}
-(void) disable:(ORUInt) index
{
   [_disabled[index] setValue:1];
}
-(void) enable:(ORUInt) index
{
   [_disabled[index] setValue:0];
}
-(ORBool) isEnable:(ORUInt) index;
{
   return ![_disabled[index] value];
}
-(id<ORIntRange>) range
{
   return [_vars range];
}
-(ORInt) low
{
   return [_vars low];
}
-(ORInt) up
{
   return [_vars up];
}
-(NSUInteger) count
{
   return [_vars count];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
   return [_vars countByEnumeratingWithState:state objects:stackbuf count:len];
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"DisabledFloatVarArray<OR>:%03d(v:%@,d:%@)",_name,_vars,_disabled];
}
@end

@implementation ORDisabledRationalVarArrayI{
   id<ORVarArray>          _vars;
   id<ORTrailableIntArray>      _disabled;
}
-(id<ORDisabledRationalVarArray>) init:(id<ORVarArray>) vars engine:(id<ORSearchEngine>)engine
{
   self = [super init];
   _vars = vars;
   _disabled = [ORFactory trailableIntArray:engine range:[vars range] value:0];
   return self;
}
-(void) dealloc
{
   [super dealloc];
}
-(id<ORVar>) at: (ORInt) value
{
   return [_vars at:value];
}
-(void) set: (id<ORVar>) x at: (ORInt) value
{
   [_vars set:x at:value];
}
-(id<ORVar>) objectAtIndexedSubscript: (NSUInteger) key
{
   return [_vars objectAtIndexedSubscript:key];
}
-(void) setObject: (id<ORRationalVar>) newValue atIndexedSubscript: (NSUInteger) idx
{
   [_vars setObject:newValue atIndexedSubscript:idx];
}
-(void) disable:(ORUInt) index
{
   [_disabled[index] setValue:1];
}
-(void) enable:(ORUInt) index
{
   [_disabled[index] setValue:0];
}
-(ORBool) isEnable:(ORUInt) index;
{
   return ![_disabled[index] value];
}
-(id<ORIntRange>) range
{
   return [_vars range];
}
-(ORInt) low
{
   return [_vars low];
}
-(ORInt) up
{
   return [_vars up];
}
-(NSUInteger) count
{
   return [_vars count];
}
- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state
                                  objects:(id *)stackbuf
                                    count:(NSUInteger)len
{
   return [_vars countByEnumeratingWithState:state objects:stackbuf count:len];
}
-(NSString*) description
{
   return [NSString stringWithFormat:@"DisabledRationalVarArray<OR>:%03d(v:%@,d:%@)",_name,_vars,_disabled];
}
@end
