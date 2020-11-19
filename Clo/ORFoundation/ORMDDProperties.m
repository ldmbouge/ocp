#import <ORFoundation/ORMDDProperties.h>

@implementation MDDPropertyDescriptor
-(id) initMDDPropertyDescriptor:(short)pId {
    self = [super init];
   _id = pId;
   _byteOffset = 0;
   return self;
}
-(int) storageSize { return 0; }
-(int) setOffset:(int)bitOffset {
    int lastByteOffset = bitOffset & 0x7;
    if (lastByteOffset != 0) {
       bitOffset = (bitOffset | 0x7) + 1;
    }
    _byteOffset = bitOffset >> 3;
    return bitOffset + [self storageSize];
}
-(int) byteOffset { return _byteOffset; }
-(void) initializeState:(char*)state { return; }
-(int) get:(char*)state { return 0; }
-(void) set:(int)value forState:(char*)state { return; }
-(bool) diff:(char*)left to:(char*)right { return true; }
-(int) initialValue { return 0; }
@end
@implementation MDDPShort
-(id) initMDDPShort:(short)pId initialValue:(short)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   return self;
}
-(int) storageSize { return 16; }
-(void) initializeState:(char*)state {
    *(short*)(&state[_byteOffset]) = _initialValue;
}
-(int) get:(char*)state {
   return *(short*)&state[_byteOffset];
}
-(void) set:(int)value forState:(char*)state {
    *(short*)(&state[_byteOffset]) = value;
    return;
}
-(bool) diff:(char*)left to:(char*)right {
    return *(short*)&left[_byteOffset] != *(short*)&right[_byteOffset];
}
-(int) initialValue { return _initialValue; }
@end
@implementation MDDPInt
-(id) initMDDPInt:(short)pId initialValue:(int)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   return self;
}
-(int) storageSize { return 32; }
-(void) initializeState:(char*)state {
    *(int*)(&state[_byteOffset]) = _initialValue;
}
-(int) get:(char*)state {
   return *(int*)&state[_byteOffset];
}
-(void) set:(int)value forState:(char*)state {
    *(int*)(&state[_byteOffset]) = value;
    return;
}
-(bool) diff:(char*)left to:(char*)right {
    return *(int*)&left[_byteOffset] != *(int*)&right[_byteOffset];
}
-(int) initialValue { return _initialValue; }
@end

@implementation MDDPBit
-(id) initMDDPBit:(short)pId initialValue:(bool)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   _bitmask = 0x1 << (pId & 0x7);
   return self;
}
-(int) storageSize { return 1; }
-(void) initializeState:(char*)state {
   state[_byteOffset] = _initialValue ? (state[_byteOffset] | _bitmask) : (state[_byteOffset] & !_bitmask);
}
-(int) get:(char*)state {
   return (unsigned char)(state[_byteOffset] & _bitmask) == _bitmask;
}
-(void) set:(int)value forState:(char*)state {
    state[_byteOffset] = value ? (state[_byteOffset] | _bitmask) : (state[_byteOffset] & !_bitmask);
    return;
}
-(bool) diff:(char*)left to:(char*)right {
    return (left[_byteOffset] & _bitmask) != (right[_byteOffset] & _bitmask);
}
-(int) initialValue { return _initialValue; }
@end

@implementation MDDPBitSequence
-(id) initMDDPBitSequence:(short)pId initialValue:(bool)initialValue numBits:(int)numBits {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
    _numBytes = ceil(numBits/8.0);
   return self;
}
-(int) storageSize { return _numBytes*8; }
-(void) initializeState:(char*)state {
    for (int i = 0; i < _numBytes; i++) {
        state[_byteOffset + i] = _initialValue ? (0xFF) : (0x00);
    }
}
-(char*) getBitSequence:(char*)state {
    return state + _byteOffset;
   //return (unsigned char)(state[_byteOffset] & _bitmask) == _bitmask;
}
-(void) setBitSequence:(char*)value forState:(char*)state {
    memcpy(state + _byteOffset, value, _numBytes);
}
-(bool) diff:(char*)left to:(char*)right {
    for (int i = 0; i < _numBytes; i++) {
        if (left[_byteOffset + i] != right[_byteOffset + i]) {
            return true;
        }
    }
    return true;
}
-(int) initialValue { return _initialValue; }
@end

@implementation MDDPWindowShort
-(id) initMDDPWindowShort:(short)pId initialValue:(short)initialValue defaultValue:(short)defaultValue windowSize:(int)windowSize {
    self = [super initMDDPropertyDescriptor:pId];
    _initialValue = initialValue;
    _defaultValue = defaultValue;
    _windowSize = windowSize;
    return self;
}
-(int) storageSize { return _windowSize*16; }
-(void) initializeState:(char*)state {
    short* stateArray = (short*)&state[_byteOffset];
    stateArray[0] = _initialValue;
    for (int i = 1; i < _windowSize; i++) {
        stateArray[i] = _defaultValue;
    }
}
-(short) get:(char*)state at:(int)index {
    return ((short*)&state[_byteOffset])[index];
}
-(void) set:(short)value forState:(char*)state at:(int)index {
    ((short*)&state[_byteOffset])[index] = value;
}
-(void) set:(char*)value forState:(char*)state slideBy:(int)numSlide {
    memcpy(state + _byteOffset + (numSlide * 2), value + _byteOffset, (_windowSize-numSlide) * 2);
}
-(void) set:(char*)state toMinOf:(char*)state1 and:(char*)state2 {
    short* stateArray = (short*)&state[_byteOffset];
    short* state1Array = (short*)&state1[_byteOffset];
    short* state2Array = (short*)&state2[_byteOffset];
    
    for (int i = 0; i < _windowSize; i++) {
        stateArray[i] = state1Array[i] < state2Array[i] ? state1Array[i] : state2Array[i];
    }
}
-(void) set:(char*)state toMaxOf:(char*)state1 and:(char*)state2 {
    short* stateArray = (short*)&state[_byteOffset];
    short* state1Array = (short*)&state1[_byteOffset];
    short* state2Array = (short*)&state2[_byteOffset];
    
    for (int i = 0; i < _windowSize; i++) {
        stateArray[i] = state1Array[i] > state2Array[i] ? state1Array[i] : state2Array[i];
    }
}
@end

@implementation MDDStateDescriptor {
@protected
    MDDPropertyDescriptor** _properties;
}
-(id) initMDDStateDescriptor:(int)numProperties {
    self = [super init];
    _properties = malloc(numProperties * sizeof(MDDPropertyDescriptor*));
    _currentOffset = 0;
    _numProperties = numProperties;
    _currentPropertyIndex = 0;
    return self;
}
-(id) initMDDStateDescriptor {
    self = [super init];
    _properties = nil;
    _currentOffset = 0;
    _currentPropertyIndex = 0;
    _numProperties = 0;
    return self;
}
-(int) numProperties { return _numProperties; }
-(void) addNewProperties:(int)num {
    MDDPropertyDescriptor** newProperties = malloc((_numProperties+num) * sizeof(MDDPropertyDescriptor*));
    for (int i = 0; i < _numProperties; i++) {
        newProperties[i] = _properties[i];
    }
    free(_properties);
    _properties = newProperties;
    _numProperties += num;
}
-(void) addStateProperty:(MDDPropertyDescriptor*)property {
    _currentOffset = [property setOffset:_currentOffset];
    _properties[_currentPropertyIndex] = [property retain];
    _currentPropertyIndex++;
}
-(void) initializeState:(char*)state {
    for (int i = 0; i < _numProperties; i++) {
        [_properties[i] initializeState:state];
    }
}
-(MDDPropertyDescriptor**) properties {
    return _properties;
}
-(int) getProperty:(int)propertyIndex forState:(char*)state {
    return [_properties[propertyIndex] get:state];
}
-(void) setProperty:(int)propertyIndex to:(int)value forState:(char*)state {
    [_properties[propertyIndex] set:value forState:(char*)state];
    return;
}
-(int) byteOffsetForProperty:(int)propertyIndex {
    return [_properties[propertyIndex] byteOffset];
}
-(int) numBytes {
    int lastByteOffset = _currentOffset & 0x1F;
    if (lastByteOffset != 0) {
        return ((_currentOffset | 0x1F) + 1) >> 3;
    }
    return _currentOffset >> 3;
}
-(void) dealloc {
    for (int i = 0; i < _numProperties; i++) {
        [_properties[i] release];
    }
    free(_properties);
    [super dealloc];
}
@end
