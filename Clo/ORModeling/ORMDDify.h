/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <Foundation/Foundation.h>
#import <ORFoundation/ORVisit.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORFoundation/ORVisit.h>

@interface CustomState : NSObject {
@protected
    int _variableIndex;
    //    char* _stateChar;
    int _domainMin;
    int _domainMax;
}
-(id) initClassState:(int)domainMin domainMax:(int)domainMax;
-(id) initRootState:(CustomState*)classState variableIndex:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState assignedValue:(int)edgeValue variableIndex:(int)variableIndex;
-(id) initState:(CustomState*)parentNodeState variableIndex:(int)variableIndex;
//-(char*) stateChar;
-(int) variableIndex;
-(int) domainMin;
-(int) domainMax;
-(void) mergeStateWith:(CustomState*)other;
-(int) numPathsWithNextVariable:(int)variable;
-(NSArray*) tempAlterStateAssigningValue:(int)value withNextVariable:(int)nextVariable;
-(void) undoChanges:(NSArray*)savedChanges;
-(bool) canChooseValue:(int)value forVariable:(int)variable;
-(int) stateDifferential:(CustomState*)other;
-(bool) equivalentTo:(CustomState*)other;
@end

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
-(int)minState;
-(int)maxState;
-(int)lowerBound;
-(int)upperBound;
//-(int)numDigits;
-(id<ORIntSet>)set;
-(int)numVarsRemaining;
@end

@interface JointState : CustomState {
@protected
    NSMutableArray* _states;
}
-(id) initRootState:(int)variableIndex domainMin:(int)domainMin domainMax:(int)domainMax;
+(void) addStateClass:(CustomState*)stateClass withVariables:(id<ORIntVarArray>)variables;
+(void) stateClassesInit;
@end

@interface ORMDDify : ORVisitor<ORModelTransformation>
-(id) initORMDDify: (id<ORAddToModel>) target;
-(id<ORAddToModel>) target;
@end
