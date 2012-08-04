/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/

#import "CPBitConstraint.h"
#import "CPEngineI.h"

@implementation CPBitEqual

-(id) initCPBitEqual:(id) x and:(id) y 
{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
    [self propagate];
    if (![_x bound] || ![_y bound]) {
        [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
        [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
    }
    [self propagate];
   return ORSuspend;
}

-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    
    unsigned int* up = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* low = alloca(sizeof(unsigned int)*wordLength);
    unsigned int  upXORlow;
        
    for(int i=0;i<wordLength;i++){
        up[i] = xUp[i]._val & yUp[i]._val;
        low[i] = xLow[i]._val | yLow[i]._val;
        upXORlow = up[i] ^ low[i];
        if(((upXORlow & (~up[i])) & (upXORlow & low[i])) != 0){
            failNow();
        }
    }

    [_x setLow: low];
    [_y setLow: low];
    [_x setUp: up];
    [_y setUp: up];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitNOT

-(id) initCPBitNOT:(id) x equals:(id) y 
{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
    [self propagate];
    if (![_x bound] || ![_y bound]) {
        [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
        [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
    }
   [self propagate];
   return ORSuspend;
}

-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int  upXORlow;

    bool    inconsistencyFound = false;

    for(int i=0;i<wordLength;i++){
        //x_k=0 => y_k=1
        newYLow[i] = ~xUp[i]._val | yLow[i]._val;
        
        //x_k=1 => y_k=0
        newYUp[i] = ~xLow[i]._val & yUp[i]._val;
        
        //y_k=0 => x_k=1
        newXLow[i] = ~yUp[i]._val | xLow[i]._val;
        
        //y_k=1 => x_k=0
        newXUp[i] = ~yLow[i]._val & xUp[i]._val;
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= ((upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]));

        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        
        if (inconsistencyFound)
            failNow();

    }
    
    [_x setLow: newXLow];
    [_y setLow: newYLow];
    [_x setUp: newXUp];
    [_y setUp: newYUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitAND
-(id) initCPBitAND:(id)x and:(id)y equals:(id)z{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;

    bool    inconsistencyFound = false;
    
    for(int i=0;i<wordLength;i++){
        
        // x_k=1 & y_k=1 => z_k=1
        newZLow[i] = (xLow[i]._val & yLow[i]._val) | zLow[i]._val;
        
        //z_k=1 => x_k=1
        //z_k=1 => y_k=1
        newXLow[i] = xLow[i]._val | zLow[i]._val;
        newYLow[i] = yLow[i]._val | zLow[i]._val;
        
        //z_k=0 & y_k=1 =>x_k=0
        newXUp[i] = (~(~zUp[i]._val & yLow[i]._val)) & xUp[i]._val;

        //z_k=0 & x_k=1 =>y_k=0
        newYUp[i] = (~(~zUp[i]._val & xLow[i]._val)) & yUp[i]._val;
        
        //x_k=0 | y_k=0 =>z_k=0
        newZUp[i] = (xUp[i]._val & yUp[i]._val) & zUp[i]._val; 
        
//        up[i] = ~((~xUp[i]) & (~yUp[i])) | (~zUp[i]);
//        low[i] = (xLow[i] & yLow[i]) | zLow[i];
//        newZUp[i] = low[i] | zLow[i];
//        newZLow[i] = ~((~up[i]) | (~zLow[i]));
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }

    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitOR
-(id) initCPBitOR:(id)x or:(id)y equals:(id)z{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
    
    for(int i=0;i<wordLength;i++){
        
        // x_k=1 | y_k=1 => z_k=1
        newZLow[i] = xLow[i]._val | yLow[i]._val | zLow[i]._val;
        
        //z_k=0 => x_k=0
        //z_k=0 => y_k=0
        newXUp[i] = zUp[i]._val & xUp[i]._val;
        newYUp[i] = zUp[i]._val & yUp[i]._val;
        
        //z_k=1 & y_k=0 =>x_k=1
        newXLow[i] =  (~yUp[i]._val & zLow[i]._val) | xLow[i]._val;
        
        //z_k=1 & x_k=0 =>y_k=1
        newYLow[i] =  (~xUp[i]._val & zLow[i]._val) | yLow[i]._val;
        
        //x_k=0 & y_k=0 =>z_k=0
        newZUp[i] = (xUp[i]._val | yUp[i]._val) & zUp[i]._val; 
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
           failNow();
    }
    
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
    [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    _z = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitXOR
-(id) initCPBitXOR:(id)x xor:(id)y equals:(id)z{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];   
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
    
    for(int i=0;i<wordLength;i++){
        
        // x_k=0 & y_k=0 => z_k=0
        // x_k=1 & y_k=1 => z_k=0
//        newZUp[i] = ~((~xUp[i]._val & ~yUp[i]._val) | (xLow[i]._val & yLow[i]._val) | ~zUp[i]._val);
        newZUp[i] = (xUp[i]._val | yUp[i]._val) & ~(xLow[i]._val & yLow[i]._val) & zUp[i]._val;
        
        //x_k=0 & y_k=1 => z_k=1
        //x_k=1 & y_k=0 => z_k=1
        newZLow[i] = (~xUp[i]._val & yLow[i]._val) | (xLow[i]._val & ~yUp[i]._val) | zLow[i]._val;
        
        //z_k=0 & y_k=0 => x_k=0
        //z_k=1 & y_k=1 => x_k=0
        newXUp[i] = (zUp[i]._val | yUp[i]._val) & ~(yLow[i]._val & zLow[i]._val) & xUp[i]._val;
        
        //z_k=0 & y_k=1 => x_k=1
        //z_k=1 & y_k=0 => x_k=1
        newXLow[i] = (~zUp[i]._val & yLow[i]._val) | (zLow[i]._val & ~yUp[i]._val) | xLow[i]._val;
        
        //z_k=0 & x_k=0 => y_k=0
        //z_k=1 & x_k=1 => y_k=0
        newYUp[i] = (zUp[i]._val | xUp[i]._val) & ~(xLow[i]._val & zLow[i]._val) & yUp[i]._val;
        
        //z_k=0 & x_k=1 => y_k=1
        //z_k=1 & x_k=0 => y_k=1
        newYLow[i] =  (~zUp[i]._val & xLow[i]._val) | (zLow[i]._val & ~xUp[i]._val) | yLow[i]._val;
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }
    
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
    [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    _z = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitIF
-(id) initCPBitIF: (id) w equalsOneIf:(id) x equals: (id) y andZeroIfXEquals: (id) z{
    self = [super initCPActiveConstraint:[x solver]];
    _w = w;
    _x = x;
    _y = y;
    _z = z;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{    
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* wLow = [_w getLow];
    TRUInt* wUp = [_w getUp];
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];
    
    unsigned int* newWUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newWLow = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    
    unsigned int fixed;
    unsigned int opposite;
    unsigned int trueInWY;
    unsigned int trueInWZ;
    unsigned int falseInWY;
    unsigned int falseInWZ;

    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
    
    for(int i=0;i<wordLength;i++){
        
        newWUp[i] = (~xLow[i]._val | yUp[i]._val) & (xUp[i]._val | zUp[i]._val) & (yUp[i]._val | zUp[i]._val) & wUp[i]._val;
        newWLow[i] = (~xLow[i]._val | yLow[i]._val) | (xUp[i]._val | zLow[i]._val) | (yLow[i]._val & zLow[i]._val) | wLow[i]._val;
        
        fixed = ~(yLow[i]._val ^ yUp[i]._val) & ~(zLow[i]._val & zUp[i]._val);
        opposite = fixed & (yLow[i]._val ^ zLow[i]._val);
        
        trueInWY = yLow[i]._val & opposite & wLow[i]._val;
        trueInWZ = zLow[i]._val & opposite & wLow[i]._val;
        falseInWY = ~yUp[i]._val & opposite & ~wUp[i]._val;
        falseInWZ = ~zUp[i]._val & opposite & ~wUp[i]._val;
        
        newXLow[i] =  xLow[i]._val | trueInWY | falseInWY;
        newXUp[i] = xUp[i]._val & ~trueInWZ & ~falseInWZ;

        newYLow[i] =  (~xLow[i]._val | wLow[i]._val) | yLow[i]._val;
        newYUp[i] = (~xLow[i]._val | wUp[i]._val) & yUp[i]._val;
        
        newZLow[i] = (xUp[i]._val | wLow[i]._val) | xLow[i]._val;
        newZUp[i] = (xUp[i]._val | wUp[i]._val) & zUp[i]._val; 
        
        upXORlow = newWUp[i] ^ newWLow[i];
        inconsistencyFound |= (upXORlow&(~newWUp[i]))&(upXORlow & newWLow[i]);
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        upXORlow = newZUp[i] ^ newZLow[i];
        inconsistencyFound |= (upXORlow&(~newZUp[i]))&(upXORlow & newZLow[i]);
        if (inconsistencyFound)
            failNow();
    }
    [_w setLow:newWLow];
    [_w setUp:newWUp];
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
    [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    _z = [aDecoder decodeObject];
    return self;
}
@end
 
@implementation CPBitShiftL
-(id) initCPBitShiftL:(id)x shiftLBy:(int)places equals:(id)y{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    _places = places;
    return self;
    
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];} ];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int upXORlow;
    
    bool    inconsistencyFound = false;
    
        for(int i=wordLength-1;i>=0;i--){
        
        //y_k =1 => x_k-places = 1
//        if (i+(_places/32)< wordLength)
            newYUp[i] = ~((~xUp[i+(_places/32)]._val << (_places%32)) | ~yUp[i]._val);
//        else
//            newYUp[i] = 0;
        
        //z_k=0 & x_k=1 => y_k=1
        //z_k=1 & x_k=0 => y_k=1
//        if (i+(_places/32)< wordLength)
            newYLow[i] =  (xLow[i+(_places/32)]._val << (_places%32)) | yLow[i]._val;
//        else
//            newYLow[i] = 0;

        upXORlow = newYUp[i] ^ newYLow[i];
        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        
        if (inconsistencyFound)
            failNow();
    }

    for(int i=0;i<wordLength;i++){

        //z_k=0 & y_k=0 => x_k=0
        //z_k=1 & y_k=1 => x_k=0
//        if ((i-(_places/32))>=0){
            newXUp[i] = ~((~yUp[i-(_places/32)]._val >> (_places%32)) | ~xUp[i]._val);
//            newXUp[i] += newXUp[i-(_places/32)] << (32 - (_places%32));
//        }
//        else
//            newXUp[i] = 0;
        
        //z_k=0 & y_k=1 => x_k=1
        //z_k=1 & y_k=0 => x_k=1
//        if ((i-(_places/32))>=0){
            newXLow[i] = (yLow[i-(_places/32)]._val>>(_places%32)) | xLow[i]._val;
//            newXLow[i] += newXLow[i-(_places/32)] << (32 - (_places%32));
//        }
//        else
//            newXLow[i] = 0;
        
        
        
        upXORlow = newXUp[i] ^ newXLow[i];
        inconsistencyFound |= (upXORlow&(~newXUp[i]))&(upXORlow & newXLow[i]);
//        upXORlow = newYUp[i] ^ newYLow[i];
//        inconsistencyFound |= (upXORlow&(~newYUp[i]))&(upXORlow & newYLow[i]);
        
        if (inconsistencyFound)
            failNow();
        }
    
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    return self;
}
@end

@implementation CPBitADD
-(id) initCPBitAdd:(id)x plus:(id)y equals:(id)z withCarryIn:(id)cin andCarryOut:(id)cout{
    self = [super initCPActiveConstraint:[x solver]];
    _x = x;
    _y = y;
    _z = z;
    _cin = cin;
    _cout = cout;
    
    return self;
}

- (void) dealloc
{
    [super dealloc];
}

-(ORStatus) post
{
   [self propagate];
   if (![_x bound] || ![_y bound]) {
      [_x whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
      [_y whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
      [_z whenBitFixed: self at: HIGHEST_PRIO do: ^() { [self propagate];}];
   }
   [self propagate];
   return ORSuspend;
}
-(void) propagate
{
    unsigned int wordLength = [_x getWordLength];
    
    TRUInt* xLow = [_x getLow];
    TRUInt* xUp = [_x getUp];
    TRUInt* yLow = [_y getLow];
    TRUInt* yUp = [_y getUp];
    TRUInt* zLow = [_z getLow];
    TRUInt* zUp = [_z getUp];
    TRUInt* cinLow = [_z getLow];
    TRUInt* cinUp = [_z getUp];
    TRUInt* coutLow = [_z getLow];
    TRUInt* coutUp = [_z getUp];
    
    unsigned int* newXUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newXLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newYLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newZLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCinUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCinLow  = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCoutUp = alloca(sizeof(unsigned int)*wordLength);
    unsigned int* newCoutLow  = alloca(sizeof(unsigned int)*wordLength);
    
    bool    inconsistencyFound = false;

    for(int i=wordLength-1;i>=0;i--){
        
        newXUp[i] = ~((~zUp[i]._val & ~coutUp[i]._val) | (~coutUp[i]._val & yLow[i]._val & ~cinUp[i]._val) | (~coutUp[i]._val & cinLow[i]._val & ~yUp[i]._val) | (~zUp[i]._val & coutLow[i]._val & yLow[i]._val & cinLow[i]._val) | ~xUp[i]._val);
        newXLow[i] = (zLow[i]._val & coutLow[i]._val) | (zLow[i]._val & ~coutUp[i]._val & ~yUp[i]._val & ~cinUp[i]._val) | (coutLow[i]._val & yLow[i]._val & ~coutUp[i]._val) | (coutLow[i]._val & ~yUp[i]._val & cinLow[i]._val);
        
        newYUp[i] = ~((~zUp[i]._val & ~coutUp[i]._val) | (~coutUp[i]._val & ~xUp[i]._val & cinLow[i]._val) | (~coutUp[i]._val & xLow[i]._val & ~cinUp[i]._val) | (~zUp[i]._val & coutLow[i]._val & xLow[i]._val & cinLow[i]._val));
        newYLow[i] = (zLow[i]._val & coutLow[i]._val) | (zLow[i]._val & ~coutUp[i]._val & ~xUp[i]._val & ~cinUp[i]._val) | (coutLow[i]._val & ~xUp[i]._val & cinLow[i]._val) | (~coutUp[i]._val & xLow[i]._val & ~cinUp[i]._val);
        
        
        
        if (inconsistencyFound)
            failNow();
    }
    
    [_x setLow:newXLow];
    [_x setUp:newXUp];
    [_y setLow:newYLow];
    [_y setUp:newYUp];
    [_z setLow:newZLow];
    [_z setUp:newZUp];
    [_cin setLow:newCinLow];
    [_cin setUp:newCinUp];
    [_cout setLow:newCoutLow];
    [_cout setUp:newCoutUp];
}

- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_x];
    [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
    self = [super initWithCoder:aDecoder];
    _x = [aDecoder decodeObject];
    _y = [aDecoder decodeObject];
    return self;
}
@end
