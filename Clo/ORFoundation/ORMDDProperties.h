/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

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

@interface MDDPBitSequence : MDDPropertyDescriptor {
@protected
    bool _initialValue;
    int _numBytes;
}
-(id) initMDDPBitSequence:(short)pId initialValue:(bool)initialValue numBits:(int)numBits;
-(char*) getBitSequence:(char*)state;
-(void) setBitSequence:(char*)value forState:(char*)state;
@end

@interface MDDStateDescriptor : NSObject {
@protected
    int _currentPropertyIndex;
    int _numProperties;
    size_t _currentOffset;
}
-(id) initMDDStateDescriptor;
-(id) initMDDStateDescriptor:(int)numProperties;
-(void) addNewProperties:(int)num;
-(void) addStateProperty:(MDDPropertyDescriptor*)property;
-(void) initializeState:(char*)state;
-(MDDPropertyDescriptor**) properties;
-(int) getProperty:(int)propertyIndex forState:(char*)state;
-(void) setProperty:(int)propertyIndex to:(int)value forState:(char*)state;
-(size_t) byteOffsetForProperty:(int)propertyIndex;
-(size_t) numBytes;
-(int) numProperties;
@end
