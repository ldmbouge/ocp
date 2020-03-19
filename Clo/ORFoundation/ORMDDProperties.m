#import <ORFoundation/ORMDDProperties.h>

@implementation MDDPropertyDescriptor
-(id) initMDDPropertyDescriptor:(short)pId {
    self = [super init];
   _id = pId;
   _byteOffset = 0;
   return self;
}
-(size_t) storageSize { return 0; }
-(size_t) setOffset:(size_t)bitOffset {
    size_t lastByteOffset = bitOffset & 0x7;
    if (lastByteOffset != 0) {
       bitOffset = (bitOffset | 0x7) + 1;
    }
    _byteOffset = bitOffset >> 3;
    return bitOffset + [self storageSize];
}
-(size_t) byteOffset { return _byteOffset; }
-(void) initializeState:(char*)state { return; }
-(int) get:(char*)state { return 0; }
-(void) set:(int)value forState:(char*)state { return; }
-(int) initialValue { return 0; }
@end
@implementation MDDPShort
-(id) initMDDPShort:(short)pId initialValue:(short)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   return self;
}
-(size_t) storageSize { return 16; }
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
-(int) initialValue { return _initialValue; }
@end
@implementation MDDPInt
-(id) initMDDPInt:(short)pId initialValue:(int)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   return self;
}
-(size_t) storageSize { return 32; }
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
-(int) initialValue { return _initialValue; }
@end

@implementation MDDPBit
-(id) initMDDPBit:(short)pId initialValue:(bool)initialValue {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
   _bitmask = 0x1 << (pId & 0x7);
   return self;
}
-(size_t) storageSize { return 1; }
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
-(int) initialValue { return _initialValue; }
@end

@implementation MDDPBitSequence
-(id) initMDDPBitSequence:(short)pId initialValue:(bool)initialValue numBits:(int)numBits {
   self = [super initMDDPropertyDescriptor:pId];
   _initialValue = initialValue;
    _numBytes = ceil(numBits/8.0);
   return self;
}
-(size_t) storageSize { return _numBytes*8; }
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
-(int) initialValue { return _initialValue; }
@end

@implementation MDDStateDescriptor
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
-(size_t) byteOffsetForProperty:(int)propertyIndex {
    return [_properties[propertyIndex] byteOffset];
}
-(size_t) numBytes {
    size_t lastByteOffset = _currentOffset & 0x1F;
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
