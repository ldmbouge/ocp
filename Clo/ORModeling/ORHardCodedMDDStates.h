#import "ORCustomMDDStates.h"

//These methods are going to be pretty badly out of date and won't work without a lot of TLC

@interface CustomBDDState : CustomState {   //A state with a list of booleans corresponding to whether or not each variable can be assigned 1
@protected
    bool* _state;
}
-(bool*) state;
@end

@interface KnapsackBDDState : CustomBDDState {
@protected
    int _weightSum;
    id<ORIntVar> _capacity;
    //    int _capacityNumDigits;
    id<ORIntArray> _weights;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax capacity:(id<ORIntVar>)capacity weights:(id<ORIntArray>)weights;
-(int) weightSum;
-(int) getWeightForVariable:(int)variable;
-(int*) getWeightsForVariable:(int)variable;
-(id<ORIntVar>) capacity;
//-(int) capacityNumDigits;
-(id<ORIntArray>) weights;
@end

@interface AllDifferentMDDState : CustomState {
@protected
    bool* _state;
}
-(bool*) state;
@end

@interface AmongMDDState : CustomState {
@protected
    int _minState;
    int _maxState;
    ORInt _lowerBound;
    ORInt _upperBound;
    id<ORIntSet> _set;
    int _numVarsRemaining;
    
    //    ORInt _upperBoundNumDigits;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax setValues:(id<ORIntSet>)set lowerBound:(ORInt)lowerBound upperBound:(ORInt)upperBound numVars:(ORInt)numVars;
-(int)minState;
-(int)maxState;
-(int)lowerBound;
-(int)upperBound;
//-(int)numDigits;
-(id<ORIntSet>)set;
-(int)numVarsRemaining;
@end
