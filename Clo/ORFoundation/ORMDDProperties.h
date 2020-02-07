
@interface MDDPropertyDescriptor : NSObject {
@protected
    short _id;
    size_t _byteOffset;
}
-(id) initMDDPropertyDescriptor:(short)pId;
-(size_t) storageSize;
-(size_t) setOffset:(size_t)bitOffset;
-(size_t) byteOffset;
-(void) initializeState:(char*)state;
-(int) get:(char*)state;
-(void) set:(int)value forState:(char*)state;
-(int) initialValue;
@end
@interface MDDPShort : MDDPropertyDescriptor {
@protected
    short _initialValue;
}
-(id) initMDDPShort:(short)pId initialValue:(short)initialValue;
@end
@interface MDDPInt : MDDPropertyDescriptor {
@protected
    int _initialValue;
}
-(id) initMDDPInt:(short)pId initialValue:(int)initialValue;
@end
@interface MDDPBit : MDDPropertyDescriptor {
@protected
    bool _initialValue;
    unsigned char _bitmask;
}
-(id) initMDDPBit:(short)pId initialValue:(bool)initialValue;
@end

@interface MDDStateDescriptor : NSObject {
@protected
    MDDPropertyDescriptor** _properties;
    int _numProperties;
    size_t _currentOffset;
}
-(id) initMDDStateDescriptor:(int)numProperties;
-(void) addStateProperty:(MDDPropertyDescriptor*)property;
-(void) initializeState:(char*)state;
-(int) getProperty:(int)propertyIndex forState:(char*)state;
-(void) setProperty:(int)propertyIndex to:(int)value forState:(char*)state;
-(size_t) byteOffsetForProperty:(int)propertyIndex;
-(size_t) numBytes;
@end
