/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORError.h>
#import <ORFoundation/ORFactory.h>
#import "ORConstraintI.h"
#import "ORParameterI.h"
#import <ORFoundation/ORMDDProperties.h>


@implementation ORMDDStateSpecification {
   id<ORIntVarArray> _x;
   ORInt _relaxationSize;
   id _specs;
   MDDRecommendationStyle _recommendationStyle;
   bool _splitAllLayersBeforeFiltering;
   int _maxSplitIter;
   int _maxRebootDistance;
   bool _useStateExistence;
   int _numNodesSplitAtATime;
   bool _numNodesDefinedAsPercent;
   int _splittingStyle;
}
-(ORMDDStateSpecification*)initORMDDStateSpecification:(id<ORIntVarArray>)x size:(ORInt)relaxationSize specs:(id)specs recommendationStyle:(MDDRecommendationStyle)recommendationStyle splitAllLayersBeforeFiltering:(bool)splitAllLayersBeforeFiltering maxSplitIter:(int)maxSplitIter maxRebootDistance:(int)maxRebootDistance useStateExistence:(bool)useStateExistence numNodesSplitAtATime:(int)numNodesSplitAtATime numNodesDefinedAsPercent:(bool)numNodesDefinedAsPercent splittingStyle:(int)splittingStyle {
   self = [super init];
   _x = x;
   _relaxationSize = relaxationSize;
   _specs = [specs retain];
   _recommendationStyle = recommendationStyle;
   _splitAllLayersBeforeFiltering = splitAllLayersBeforeFiltering;
   _maxSplitIter = maxSplitIter;
   _maxRebootDistance = maxRebootDistance;
   _useStateExistence = useStateExistence;
   _numNodesSplitAtATime = numNodesSplitAtATime;
   _numNodesDefinedAsPercent = numNodesDefinedAsPercent;
   _splittingStyle = splittingStyle;
   return self;
}
-(void)dealloc
{
   [_specs release];
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@)",[self class],self,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMDDStateSpecification:self];
}
-(id<ORIntVarArray>) vars
{
   return _x;
}
-(ORInt) relaxationSize
{
   return _relaxationSize;
}
-(bool) splitAllLayersBeforeFiltering
{
   return _splitAllLayersBeforeFiltering;
}
-(int) maxSplitIter
{
   return _maxSplitIter;
}
-(int) maxRebootDistance
{
   return _maxRebootDistance;
}
-(bool) useStateExistence
{
   return _useStateExistence;
}
-(int) numNodesSplitAtATime
{
   return _numNodesSplitAtATime;
}
-(bool) numNodesDefinedAsPercent
{
   return _numNodesDefinedAsPercent;
}
-(int) splittingStyle
{
   return _splittingStyle;
}
-(id) specs
{
   return _specs;
}
-(MDDRecommendationStyle) recommendationStyle { return _recommendationStyle; }
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
@end

@implementation ORMDDSpecs {
   id<ORIntVarArray> _x;
   MDDPropertyDescriptor** _forwardStateProperties;
   MDDPropertyDescriptor** _reverseStateProperties;
   MDDPropertyDescriptor** _combinedStateProperties;
   DDArcSetTransitionClosure* _forwardTransitionClosures;
   DDArcSetTransitionClosure* _reverseTransitionClosures;
   DDMergeClosure* _forwardRelaxationClosures;
   DDMergeClosure* _reverseRelaxationClosures;
   DDUpdatePropertyClosure* _updatePropertyClosures;
   DDArcExistsClosure _arcExistsClosure;
   DDStateExistsClosure _stateExistsClosure;
   id<ORIntVar> _fixpointVar;
   DDFixpointBoundClosure _fixpointMin;
   DDFixpointBoundClosure _fixpointMax;
   DDNodeSplitValueClosure _nodeSplitValueClosure;
   DDCandidateSplitValueClosure _candidateSplitValueClosure;
   DDStateEquivalenceClassClosure _approximateEquivalenceClosure;
   int _numForwardProperties, _numReverseProperties, _numCombinedProperties;
   bool _dualDirectional;
   int** _forwardPropertyImpact;
   int* _forwardPropertyImpactCount;
   int** _reversePropertyImpact;
   int* _reversePropertyImpactCount;
   int _constraintPriority;
   
   int* _numBitsInByteLookup;
}
-(ORMDDSpecs*)initORMDDSpecs:(id<ORIntVarArray>)x numForwardProperties:(int)numForwardProperties numReverseProperties:(int)numReverseProperties numCombinedProperties:(int)numCombinedProperties constraintPriority:(int)constraintPriority {
   self = [super initORConstraintI];
   _x = x;
   
   _numForwardProperties = numForwardProperties;
   _numReverseProperties = numReverseProperties;
   _numCombinedProperties = numCombinedProperties;
   _constraintPriority = constraintPriority;
   
   _forwardStateProperties = malloc(_numForwardProperties * sizeof(MDDPropertyDescriptor*));
   _reverseStateProperties = malloc(_numReverseProperties * sizeof(MDDPropertyDescriptor*));
   _combinedStateProperties = malloc(_numCombinedProperties * sizeof(MDDPropertyDescriptor*));
   
   _forwardTransitionClosures = malloc(_numForwardProperties * sizeof(DDArcSetTransitionClosure));
   _reverseTransitionClosures = malloc(_numReverseProperties * sizeof(DDArcSetTransitionClosure));
   
   _forwardRelaxationClosures = malloc(_numForwardProperties * sizeof(DDMergeClosure));
   _reverseRelaxationClosures = malloc(_numReverseProperties * sizeof(DDMergeClosure));
   
   _updatePropertyClosures = malloc(_numCombinedProperties * sizeof(DDUpdatePropertyClosure));
   
   _dualDirectional = false;
   
   _forwardPropertyImpact = malloc(_numForwardProperties * sizeof(int*));
   _forwardPropertyImpactCount = calloc(_numForwardProperties, sizeof(int));
   _reversePropertyImpact = malloc(_numReverseProperties * sizeof(int*));
   _reversePropertyImpactCount = calloc(_numReverseProperties, sizeof(int));
   
   _numBitsInByteLookup = malloc(256 * sizeof(int));
   _numBitsInByteLookup[0] = 0;
   for (int i = 1; i < 256; i++) {
      _numBitsInByteLookup[i] = (i & 1) + _numBitsInByteLookup[i/2];
   }
   
   return self;
}
-(bool) dualDirectional { return _dualDirectional; }
-(int) constraintPriority { return _constraintPriority; }
-(void)addForwardStateCounter:(ORInt)lookup withDefaultValue:(ORInt)value {
   if ([_x count] < 32767) {
      _forwardStateProperties[lookup] = [[MDDPShort alloc] initMDDPShort:lookup initialValue:value];
   } else {
      _forwardStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
   }
}
-(void)addForwardStateInt:(ORInt)lookup withDefaultValue:(ORInt)value {
   _forwardStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
}
-(void)addForwardStateBool:(ORInt)lookup withDefaultValue:(bool)value {
   _forwardStateProperties[lookup] = [[MDDPBit alloc] initMDDPBit:lookup initialValue:value];
}
-(void)addForwardStateBitSequence:(ORInt)lookup withDefaultValue:(bool)value size:(ORInt)size {
   _forwardStateProperties[lookup] = [[MDDPBitSequence alloc] initMDDPBitSequence:lookup initialValue:value numBits:size];
}
-(void)addForwardStateWindow:(ORInt)lookup withInitialValue:(short)initialValue defaultValue:(short)defaultValue size:(ORInt)size {
   _forwardStateProperties[lookup] = [[MDDPWindowShort alloc] initMDDPWindowShort:lookup initialValue:initialValue defaultValue:defaultValue windowSize:size];
}
-(void)addReverseStateCounter:(ORInt)lookup withDefaultValue:(ORInt)value {
   if ([_x count] < 32767) {
      _reverseStateProperties[lookup] = [[MDDPShort alloc] initMDDPShort:lookup initialValue:value];
   } else {
      _reverseStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
   }
}
-(void)addReverseStateInt:(ORInt)lookup withDefaultValue:(ORInt)value {
   _reverseStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
}
-(void)addReverseStateBool:(ORInt)lookup withDefaultValue:(bool)value {
   _reverseStateProperties[lookup] = [[MDDPBit alloc] initMDDPBit:lookup initialValue:value];
}
-(void)addReverseStateBitSequence:(ORInt)lookup withDefaultValue:(bool)value size:(ORInt)size {
   _reverseStateProperties[lookup] = [[MDDPBitSequence alloc] initMDDPBitSequence:lookup initialValue:value numBits:size];
}
-(void)addReverseStateWindow:(ORInt)lookup withInitialValue:(short)initialValue defaultValue:(short)defaultValue size:(ORInt)size {
   _reverseStateProperties[lookup] = [[MDDPWindowShort alloc] initMDDPWindowShort:lookup initialValue:initialValue defaultValue:defaultValue windowSize:size];
}
-(void)addCombinedStateCounter:(ORInt)lookup withDefaultValue:(ORInt)value {
   if ([_x count] < 32767) {
      _combinedStateProperties[lookup] = [[MDDPShort alloc] initMDDPShort:lookup initialValue:value];
   } else {
      _combinedStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
   }
}
-(void)addCombinedStateInt:(ORInt)lookup withDefaultValue:(ORInt)value {
   _combinedStateProperties[lookup] = [[MDDPInt alloc] initMDDPInt:lookup initialValue:value];
}
-(void)addCombinedStateBool:(ORInt)lookup withDefaultValue:(bool)value {
   _combinedStateProperties[lookup] = [[MDDPBit alloc] initMDDPBit:lookup initialValue:value];
}
-(void)addCombinedStateBitSequence:(ORInt)lookup withDefaultValue:(bool)value size:(ORInt)size {
   _combinedStateProperties[lookup] = [[MDDPBitSequence alloc] initMDDPBitSequence:lookup initialValue:value numBits:size];
}


typedef int (*GetPropIMP)(id,SEL,char*);
typedef char* (*GetBitsPropIMP)(id,SEL,char*);
typedef void (*SetPropIMP)(id,SEL,int,char*);
typedef void (*SetBitsPropIMP)(id,SEL,char*,char*);
-(void)setAsDualDirectionalAmongConstraint:(id<ORIntRange>)range lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   ORInt minDom = [range low];
   ORInt maxDom = [range up];
   ORInt domSize = [range size];
   int minValue = [values min];
   int maxValue = [values max];
   int numValues = [values size];
   
   int minCount = 0, maxCount = 1;
   MDDPropertyDescriptor* minDownProp = _forwardStateProperties[minCount];
   MDDPropertyDescriptor* maxDownProp = _forwardStateProperties[maxCount];
   MDDPropertyDescriptor* minUpProp = _reverseStateProperties[minCount];
   MDDPropertyDescriptor* maxUpProp = _reverseStateProperties[maxCount];
   
   SEL getSel = @selector(get:);
   GetPropIMP getMinDown = (GetPropIMP)[minDownProp methodForSelector:getSel];
   GetPropIMP getMaxDown = (GetPropIMP)[maxDownProp methodForSelector:getSel];
   GetPropIMP getMinUp = (GetPropIMP)[minUpProp methodForSelector:getSel];
   GetPropIMP getMaxUp = (GetPropIMP)[maxUpProp methodForSelector:getSel];

   
   //Special cases to have better performance
   //BDD
   if (domSize == 2 && numValues == 1) {
      int theValue = minValue;
      int otherValue = (minDom == theValue) ? maxDom : minDom;
      _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
         bool valueInSet = value == theValue;
         if (childReverse != nil) {
            return getMinDown(minDownProp, getSel, parentForward) + valueInSet + getMinUp(minUpProp, getSel, childReverse) <= ub &&
            getMaxDown(maxDownProp, getSel, parentForward) + valueInSet + getMaxUp(maxUpProp, getSel, childReverse) >= lb;
         }
         return getMinDown(minDownProp, getSel, parentForward) + valueInSet <= ub;
      } copy];
      
      _forwardTransitionClosures[minCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInAll = !valueSet[otherValue];
         [minDownProp set:getMinDown(minDownProp,getSel,forward) + valueInAll forState:newState];
         return numArcs > 1;
      } copy];
      _forwardTransitionClosures[maxCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInSome = valueSet[theValue];
         [maxDownProp set:getMaxDown(maxDownProp,getSel,forward) + valueInSome forState:newState];
         return numArcs > 1;
      } copy];
      
      _reverseTransitionClosures[minCount] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInAll = !valueSet[otherValue];
         [minUpProp set:getMinUp(minUpProp,getSel,reverse) + valueInAll forState:newState];
         return numArcs > 1;
      } copy];
      _reverseTransitionClosures[maxCount] = [^(char* newState, char* reverse, char* combined,bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInSome = valueSet[theValue];
         [maxUpProp set:getMaxUp(maxUpProp,getSel,reverse) + valueInSome forState:newState];
         return numArcs > 1;
      } copy];
   } else {
      bool* valueInSetLookup = calloc(domSize, sizeof(bool));
      valueInSetLookup -= minDom;
      [values enumerateWithBlock:^(ORInt value) {
         valueInSetLookup[value] = true;
      }];
      
      _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
         int valueInSet = (value >= minValue && value <= maxValue && valueInSetLookup[value]);
         if (childReverse != nil) {
            return getMinDown(minDownProp, getSel, parentForward) + valueInSet + getMinUp(minUpProp, getSel, childReverse) <= ub &&
            getMaxDown(maxDownProp, getSel, parentForward) + valueInSet + getMaxUp(maxUpProp, getSel, childReverse) >= lb;
         }
         return getMinDown(minDownProp, getSel, parentForward) + valueInSet <= ub;
      } copy];
      _forwardTransitionClosures[minCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInSome = false;
         bool valueInAll = true;
         if (numArcs > numValues) {
            valueInAll = false;
         }
         for (int i = minDom; numArcs; i++) {
            if (valueSet[i]) {
               numArcs--;
               if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
                  valueInSome = true;
               } else {
                  valueInAll = false;
               }
               if (valueInSome && !valueInAll) {
                  break;
               }
            }
         }
         [minDownProp set:getMinDown(minDownProp,getSel,forward) + valueInAll forState:newState];
         return valueInSome && !valueInAll;
      } copy];
      _forwardTransitionClosures[maxCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInSome = false;
         bool valueInAll = true;
         if (numArcs > numValues) {
            valueInAll = false;
         }
         for (int i = minDom; numArcs; i++) {
            if (valueSet[i]) {
               numArcs--;
               if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
                  valueInSome = true;
               } else {
                  valueInAll = false;
               }
               if (valueInSome && !valueInAll) {
                  break;
               }
            }
         }
         [maxDownProp set:getMaxDown(maxDownProp,getSel,forward) + valueInSome forState:newState];
         return valueInSome && !valueInAll;
      } copy];
      
      
      _reverseTransitionClosures[minCount] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInAll = true;
         for (int i = minDom; i <= maxDom; i++) {
            if (valueSet[i] && !(i >= minValue && i <= maxValue && valueInSetLookup[i])) {
               valueInAll = false;
               break;
            }
         }
         [minUpProp set:getMinUp(minUpProp,getSel,reverse) + valueInAll forState:newState];
         return numArcs > 1;
      } copy];
      _reverseTransitionClosures[maxCount] = [^(char* newState, char* reverse, char* combined,bool* valueSet, int numArcs, int minDom, int maxDom) {
         bool valueInSome = false;
         for (int i = minDom; i <= maxDom; i++) {
            if (valueSet[i] && i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               valueInSome = true;
               break;
            }
         }
         [maxUpProp set:getMaxUp(maxUpProp,getSel,reverse) + valueInSome forState:newState];
         return numArcs > 1;
      } copy];
   }
   
   _forwardPropertyImpactCount[minCount] = 1;
   _forwardPropertyImpactCount[maxCount] = 1;
   _forwardPropertyImpact[minCount] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[maxCount] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minCount][0] = minCount;
   _forwardPropertyImpact[maxCount][0] = maxCount;

   _reversePropertyImpactCount[minCount] = 1;
   _reversePropertyImpactCount[maxCount] = 1;
   _reversePropertyImpact[minCount] = malloc(1 * sizeof(int));
   _reversePropertyImpact[maxCount] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minCount][0] = minCount;
   _reversePropertyImpact[maxCount][0] = maxCount;
   
   _forwardRelaxationClosures[minCount] = [^(char* newState, char* state1,char* state2) {
      [minDownProp set:min(getMinDown(minDownProp,getSel,state1), getMinDown(minDownProp,getSel,state2)) forState:newState];
   } copy];
   _forwardRelaxationClosures[maxCount] = [^(char* newState, char* state1,char* state2) {
      [maxDownProp set:max(getMaxDown(maxDownProp,getSel,state1), getMaxDown(maxDownProp,getSel,state2)) forState:newState];
   } copy];
   _reverseRelaxationClosures[minCount] = [^(char* newState, char* state1,char* state2) {
      [minUpProp set:min(getMinUp(minUpProp,getSel,state1), getMinUp(minUpProp,getSel,state2)) forState:newState];
   } copy];
   _reverseRelaxationClosures[maxCount] = [^(char* newState, char* state1,char* state2) {
      [maxUpProp set:max(getMaxUp(maxUpProp,getSel,state1), getMaxUp(maxUpProp,getSel,state2)) forState:newState];
   } copy];
   
   _stateExistsClosure = [^(char* forward, char* reverse, char* combined) {
      return getMinDown(minDownProp, getSel, forward) + getMinUp(minUpProp, getSel, reverse) <= ub &&
             getMaxDown(maxDownProp, getSel, forward) + getMaxUp(maxUpProp, getSel, reverse) >= lb;
   } copy];
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
        _candidateSplitValueClosure = [^(NSArray* candidate) {
           return -[candidate count];
        } copy];
     }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      //   return getMinDown(minDownProp, getSel, forward) * 100 +
      //        getMaxDown(maxDownProp, getSel, forward);
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         return (lb - (getMinDown(minDownProp, getSel, forward) + getMinUp(minUpProp, getSel, reverse)) > 3) +
              2*(ub - (getMaxDown(maxDownProp, getSel, forward) + getMaxUp(maxUpProp, getSel, reverse)) > 3);
      } copy];
   }
}
-(void)defineAsAbsDiff:(id<ORIntRange>)range nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   //|x - y| = z
   _dualDirectional = true;
   ORInt minDom = [range low];
   ORInt maxDom = [range up];
   ORInt domSize = [range size];
   int numBytes = ceil(domSize/8.0);
   int xValueDownIndex = 0, yValueDownIndex = 1, layerIndexIndex = 2,
       yValueUpIndex = 0, zValueUpIndex = 1, layerIndexUpIndex = 2;
   MDDPropertyDescriptor* xValueDownProp = _forwardStateProperties[xValueDownIndex];
   MDDPropertyDescriptor* yValueDownProp = _forwardStateProperties[yValueDownIndex];
   MDDPropertyDescriptor* layerIndexProp = _forwardStateProperties[layerIndexIndex];
   MDDPropertyDescriptor* yValueUpProp = _reverseStateProperties[yValueUpIndex];
   MDDPropertyDescriptor* zValueUpProp = _reverseStateProperties[zValueUpIndex];
   MDDPropertyDescriptor* layerIndexUpProp = _reverseStateProperties[layerIndexUpIndex];
   
   SEL getBitSel = @selector(getBitSequence:);
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetBitsPropIMP getXValueDown = (GetBitsPropIMP)[xValueDownProp methodForSelector:getBitSel];
   GetBitsPropIMP getYValueDown = (GetBitsPropIMP)[yValueDownProp methodForSelector:getBitSel];
   GetPropIMP getLayerIndex = (GetPropIMP)[layerIndexProp methodForSelector:getSel];
   SetPropIMP setLayerIndex = (SetPropIMP)[layerIndexProp methodForSelector:setSel];
   GetBitsPropIMP getYValueUp = (GetBitsPropIMP)[yValueUpProp methodForSelector:getBitSel];
   GetBitsPropIMP getZValueUp = (GetBitsPropIMP)[zValueUpProp methodForSelector:getBitSel];
   GetPropIMP getLayerIndexUp = (GetPropIMP)[layerIndexUpProp methodForSelector:getSel];
   SetPropIMP setLayerIndexUp = (SetPropIMP)[layerIndexUpProp methodForSelector:setSel];


   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      int layerIndex = getLayerIndex(layerIndexProp, getSel, parentForward);
      if (layerIndex == 2) {
         //Filter z
         char* xValues = getXValueDown(xValueDownProp, getBitSel, parentForward);
         char* yValues = getYValueDown(yValueDownProp, getBitSel, parentForward);
         for (int i = minDom; i <= maxDom; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (xValues[byteIndex] & bitMask) {
               int yOption1 = i - value;
               if (yOption1 >= minDom && yOption1 <= maxDom) {
                  shiftedValue = yOption1 - minDom;
                  byteIndex = yOption1 >> 3;
                  bitMask = 0x1 << (yOption1 & 0x7);
                  if (yValues[byteIndex] & bitMask) {
                     return true;
                  }
               }
               int yOption2 = i + value;
               if (yOption2 >= minDom && yOption2 <= maxDom) {
                  shiftedValue = yOption2 - minDom;
                  byteIndex = yOption2 >> 3;
                  bitMask = 0x1 << (yOption2 & 0x7);
                  if (yValues[byteIndex] & bitMask) {
                     return true;
                  }
               }
            }
         }
         return false;
      } else {
         if (childReverse == nil) return true;
         if (layerIndex == 0) {
            //Filter x
            char* yValues = getYValueUp(yValueUpProp, getBitSel, childReverse);
            char* zValues = getZValueUp(zValueUpProp, getBitSel, childReverse);
            for (int i = minDom; i <= maxDom; i++) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (shiftedValue & 0x7);
               if (yValues[byteIndex] & bitMask) {
                  int zOption1 = value - i;
                  if (zOption1 >= minDom && zOption1 <= maxDom) {
                     shiftedValue = zOption1 - minDom;
                     byteIndex = zOption1 >> 3;
                     bitMask = 0x1 << (zOption1 & 0x7);
                     if (zValues[byteIndex] & bitMask) {
                        return true;
                     }
                  }
                  int zOption2 = i - value;
                  if (zOption2 >= minDom && zOption2 <= maxDom) {
                     shiftedValue = zOption2 - minDom;
                     byteIndex = zOption2 >> 3;
                     bitMask = 0x1 << (zOption2 & 0x7);
                     if (zValues[byteIndex] & bitMask) {
                        return true;
                     }
                  }
               }
            }
            return false;
         } else {
            //Filter y
            char* xValues = getXValueDown(xValueDownProp, getBitSel, parentForward);
            char* zValues = getZValueUp(zValueUpProp, getBitSel, childReverse);
            for (int i = minDom; i <= maxDom; i++) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (i & 0x7);
               if (xValues[byteIndex] & bitMask) {
                  int zOption1 = value - i;
                  if (zOption1 >= minDom && zOption1 <= maxDom) {
                     shiftedValue = zOption1 - minDom;
                     byteIndex = zOption1 >> 3;
                     bitMask = 0x1 << (zOption1 & 0x7);
                     if (zValues[byteIndex] & bitMask) {
                        return true;
                     }
                  }
                  int zOption2 = i - value;
                  if (zOption2 >= minDom && zOption2 <= maxDom) {
                     shiftedValue = zOption2 - minDom;
                     byteIndex = zOption2 >> 3;
                     bitMask = 0x1 << (zOption2 & 0x7);
                     if (zValues[byteIndex] & bitMask) {
                        return true;
                     }
                  }
               }
            }
            return false;
         }
      }
   } copy];
      
   _forwardTransitionClosures[xValueDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [xValueDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      if (getLayerIndex(layerIndexProp, getSel, forward) == 0) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (shiftedValue & 0x7);
               newState[firstByte + byteIndex] |= bitMask;
            }
         }
         return numArcs > 1;
      } else {
         return false;
      }
   } copy];
   _forwardTransitionClosures[yValueDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [yValueDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      if (getLayerIndex(layerIndexProp, getSel, forward) == 1) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (shiftedValue & 0x7);
               newState[firstByte + byteIndex] |= bitMask;
            }
         }
         return numArcs > 1;
      } else {
         return false;
      }
   } copy];
   _forwardTransitionClosures[layerIndexIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setLayerIndex(layerIndexProp, setSel, getLayerIndex(layerIndexProp, getSel, forward)+1, newState);
      return false;
   } copy];
      
   _reverseTransitionClosures[yValueUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [yValueUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      if (getLayerIndexUp(layerIndexUpProp, getSel, reverse) == 2) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (shiftedValue & 0x7);
               newState[firstByte + byteIndex] |= bitMask;
            }
         }
         return numArcs > 1;
      } else {
         return false;
      }
   } copy];
   _reverseTransitionClosures[zValueUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [zValueUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      if (getLayerIndexUp(layerIndexUpProp, getSel, reverse) == 3) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               int shiftedValue = i - minDom;
               int byteIndex = shiftedValue >> 3;
               char bitMask = 0x1 << (shiftedValue & 0x7);
               newState[firstByte + byteIndex] |= bitMask;
            }
         }
         return numArcs > 1;
      } else {
         return false;
      }
   } copy];
   _reverseTransitionClosures[layerIndexUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setLayerIndexUp(layerIndexUpProp, setSel, getLayerIndexUp(layerIndexUpProp, getSel, reverse)-1, newState);
      return false;
   } copy];
   
   _forwardPropertyImpactCount[xValueDownIndex] = 1;
   _forwardPropertyImpactCount[yValueDownIndex] = 1;
   _forwardPropertyImpact[xValueDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[yValueDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[xValueDownIndex][0] = xValueDownIndex;
   _forwardPropertyImpact[yValueDownIndex][0] = yValueDownIndex;

   _reversePropertyImpactCount[yValueUpIndex] = 1;
   _reversePropertyImpactCount[zValueUpIndex] = 1;
   _reversePropertyImpact[yValueUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[zValueUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[yValueUpIndex][0] = yValueUpIndex;
   _reversePropertyImpact[zValueUpIndex][0] = zValueUpIndex;
   
   _forwardRelaxationClosures[xValueDownIndex] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[xValueDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   _forwardRelaxationClosures[yValueDownIndex] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[yValueDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   _forwardRelaxationClosures[layerIndexIndex] = [^(char* newState, char* state1,char* state2) {
      setLayerIndex(layerIndexProp, setSel, getLayerIndex(layerIndexProp, getSel, state1), newState);
   } copy];
   _reverseRelaxationClosures[yValueUpIndex] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[yValueUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   _reverseRelaxationClosures[zValueUpIndex] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[zValueUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   _reverseRelaxationClosures[layerIndexUpIndex] = [^(char* newState, char* state1,char* state2) {
      setLayerIndexUp(layerIndexUpProp, setSel, getLayerIndexUp(layerIndexUpProp, getSel, state1), newState);
   } copy];
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
        _candidateSplitValueClosure = [^(NSArray* candidate) {
           return -[candidate count];
        } copy];
     }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      //   return ;
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      //   return ;
      //} copy];
   }
}

-(void)defineAsGCC:(id<ORIntRange>)range lowerBounds:(int*)lb upperBounds:(int*)ub numVars:(int)numVars nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   ORInt minDom = [range low];
   ORInt maxDom = [range up];
   ORInt domSize = [range size];
   
   int minCount = 0, maxCount = 1, numAssignedIndex = 2;
   MDDPWindowShort* minDownWindowProp = (MDDPWindowShort*)_forwardStateProperties[minCount];
   MDDPWindowShort* maxDownWindowProp = (MDDPWindowShort*)_forwardStateProperties[maxCount];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedIndex];
   MDDPWindowShort* minUpWindowProp = (MDDPWindowShort*)_reverseStateProperties[minCount];
   MDDPWindowShort* maxUpWindowProp = (MDDPWindowShort*)_reverseStateProperties[maxCount];
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      bool reverseInfoExists = childReverse != nil;
      int shiftedValue = value - minDom;
      
      if (reverseInfoExists) {
         int requiredSize = 0;
         if (!([minDownWindowProp get:parentForward at:shiftedValue] + [minUpWindowProp get:childReverse at:shiftedValue] < ub[shiftedValue] &&
             [maxDownWindowProp get:parentForward at:shiftedValue] + 1 + [maxUpWindowProp get:childReverse at:shiftedValue] >= lb[shiftedValue])) {
            return false;
         }
         int setForV = [minDownWindowProp get:parentForward at:shiftedValue] + [minUpWindowProp get:childReverse at:shiftedValue] + 1;
         requiredSize += max(setForV, lb[shiftedValue]);
         for (int v = 0; v < domSize; v++) {
            if (v == shiftedValue) continue;
            if (!([minDownWindowProp get:parentForward at:v] + [minUpWindowProp get:childReverse at:v] <= ub[v] &&
                [maxDownWindowProp get:parentForward at:v] + [maxUpWindowProp get:childReverse at:v] >= lb[v])) {
               return false;
            }
            setForV = [minDownWindowProp get:parentForward at:v] + [minUpWindowProp get:childReverse at:v];
            requiredSize += max(setForV, lb[v]);
         }
         return requiredSize <= numVars;
      } else {
         return [minDownWindowProp get:parentForward at:shiftedValue] < ub[shiftedValue];
      }
   } copy];
   
   _stateExistsClosure = [^(char* forward, char* reverse, char* combined) {
      int usefulAbove = 0;
      int usefulBelow = 0;
      int missing = 0;
      int requiredSize = 0;
      int numAssignedDown = [numAssignedDownProp get:forward];
      for (int v = 0; v < domSize; v++) {
         int minDown = [minDownWindowProp get:forward at:v];
         int minUp = [minUpWindowProp get:reverse at:v];
         int setForV = minDown + minUp;
         requiredSize += max(setForV, lb[v]);
         if (setForV < lb[v]) {
            int needed = lb[v] - setForV;
            missing += needed;
            usefulAbove += min(needed, [maxDownWindowProp get:forward at:v] - minDown);
            usefulBelow += min(needed, [maxUpWindowProp get:reverse at:v] - minUp);
         }
      }
      return requiredSize <= numVars && (min(usefulAbove, numAssignedDown) + min(usefulBelow, numVars - numAssignedDown) >= missing);
   } copy];
   
   
   _forwardTransitionClosures[minCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      [minDownWindowProp set:forward forState:newState slideBy:0];
      if (numArcs == 1) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               i -= minDom;
               [minDownWindowProp set:([minDownWindowProp get:forward at:i]+1) forState:newState at:i];
               return false;
            }
         }
      }
      return true;
   } copy];
   _forwardTransitionClosures[maxCount] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      [maxDownWindowProp set:forward forState:newState slideBy:0];
      for (int v = minDomIndex; v <= maxDomIndex; v++) {
         if (valueSet[v]) {
            int shiftedValue = v - minDom;
            [maxDownWindowProp set:([maxDownWindowProp get:forward at:shiftedValue]+1) forState:newState at:shiftedValue];
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      [numAssignedDownProp set:[numAssignedDownProp get:forward]+1 forState:newState];
      return false;
   } copy];
      
   _reverseTransitionClosures[minCount] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      [minUpWindowProp set:reverse forState:newState slideBy:0];
      if (numArcs == 1) {
         for (int i = minDomIndex; i <= maxDomIndex; i++) {
            if (valueSet[i]) {
               i -= minDom;
               [minUpWindowProp set:([minUpWindowProp get:reverse at:i]+1) forState:newState at:i];
               return false;
            }
         }
      }
      return true;
   } copy];
   _reverseTransitionClosures[maxCount] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      [maxUpWindowProp set:reverse forState:newState slideBy:0];
      for (int v = minDomIndex; v <= maxDomIndex; v++) {
         if (valueSet[v]) {
            int shiftedValue = v - minDom;
            [maxUpWindowProp set:([maxUpWindowProp get:reverse at:shiftedValue]+1) forState:newState at:shiftedValue];
         }
      }
      return numArcs > 1;
   } copy];
   
   _forwardRelaxationClosures[minCount] = [^(char* newState, char* state1,char* state2) {
      [minDownWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[maxCount] = [^(char* newState, char* state1,char* state2) {
      [maxDownWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[numAssignedIndex] = [^(char* newState, char* state1,char* state2) {
      [numAssignedDownProp set:[numAssignedDownProp get:state1] forState:newState];
   } copy];
   
   _reverseRelaxationClosures[minCount] = [^(char* newState, char* state1,char* state2) {
      [minUpWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _reverseRelaxationClosures[maxCount] = [^(char* newState, char* state1,char* state2) {
      [maxUpWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   
   _forwardPropertyImpactCount[minCount] = 1;
   _forwardPropertyImpactCount[maxCount] = 1;
   _forwardPropertyImpact[minCount] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[maxCount] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minCount][0] = minCount;
   _forwardPropertyImpact[maxCount][0] = maxCount;

   _reversePropertyImpactCount[minCount] = 1;
   _reversePropertyImpactCount[maxCount] = 1;
   _reversePropertyImpact[minCount] = malloc(1 * sizeof(int));
   _reversePropertyImpact[maxCount] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minCount][0] = minCount;
   _reversePropertyImpact[maxCount][0] = maxCount;
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   } else if (nodePriorityMode == 3) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         int slack = 0;
         for (int v = 0; v < domSize; v++) {
            int setForV = [minDownWindowProp get:forward at:v] + [minUpWindowProp get:reverse at:v];
            slack += max(0, lb[v] - setForV);
         }
         return slack;
      } copy];
   } else if (nodePriorityMode == 4) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         int slack = 0;
         for (int v = 0; v < domSize; v++) {
            int setForV = [minDownWindowProp get:forward at:v] + [minUpWindowProp get:reverse at:v];
            slack += max(0, lb[v] - setForV);
         }
         return -slack;
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
        _candidateSplitValueClosure = [^(NSArray* candidate) {
           return -[candidate count];
        } copy];
   }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      // return ;
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int slack = 0;
         for (int v = 0; v < domSize; v++) {
            int setForV = [minDownWindowProp get:forward at:v] + [minUpWindowProp get:reverse at:v];
            slack += max(0, lb[v] - setForV);
         }
         return slack > 5;
      } copy];
   } else if (stateEquivalenceMode == 2) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int class = 0;
         for (int v = 0; v < domSize; v++) {
            int setForV = [minDownWindowProp get:forward at:v] + [minUpWindowProp get:reverse at:v];
            if (lb[v] - setForV > 2) {
               class = class | (1 << v);
            }
         }
         return class;
      } copy];
   } else if (stateEquivalenceMode == 3) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int class = 0;
         for (int v = 0; v < domSize; v++) {
            int setForV = [minDownWindowProp get:forward at:v] + [minUpWindowProp get:reverse at:v];
            if (lb[v] - setForV > 0) {
               class = class | (1 << v);
            }
         }
         return class;
      } copy];
   }
}

-(void) setAsDualDirectionalAllDifferent:(int)numVariables domain:(id<ORIntRange>)domain nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   
   int minDom = [domain low];
   int maxDom = [domain up];
   int domSize = maxDom - minDom + 1;
   int numBytes = ceil(domSize/8.0);
   int someDownIndex = 0, allDownIndex = 1, numAssignedDownIndex = 2,
       someUpIndex = 0, allUpIndex = 1;
   MDDPropertyDescriptor* someDownProp = _forwardStateProperties[someDownIndex];
   MDDPropertyDescriptor* allDownProp = _forwardStateProperties[allDownIndex];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedDownIndex];
   MDDPropertyDescriptor* someUpProp = _reverseStateProperties[someUpIndex];
   MDDPropertyDescriptor* allUpProp = _reverseStateProperties[allUpIndex];
   
   SEL getBitSel = @selector(getBitSequence:);
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetBitsPropIMP getSomeDown = (GetBitsPropIMP)[someDownProp methodForSelector:getBitSel];
   GetBitsPropIMP getAllDown = (GetBitsPropIMP)[allDownProp methodForSelector:getBitSel];
   GetPropIMP getNumAssignedDown = (GetPropIMP)[numAssignedDownProp methodForSelector:getSel];
   SetPropIMP setNumAssignedDown = (SetPropIMP)[numAssignedDownProp methodForSelector:setSel];
   GetBitsPropIMP getSomeUp = (GetBitsPropIMP)[someUpProp methodForSelector:getBitSel];
   GetBitsPropIMP getAllUp = (GetBitsPropIMP)[allUpProp methodForSelector:getBitSel];
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      bool reverseInfoExists = childReverse != nil;
      int shiftedValue = value - minDom;
      int byteIndex = shiftedValue >> 3;
      char bitMask = 0x1 << (shiftedValue & 0x7);
      char* allUp;
      char* someUp;
      if (reverseInfoExists) {
         allUp = getAllUp(allUpProp, getBitSel, childReverse);
         someUp = getSomeUp(someUpProp, getBitSel, childReverse);
      }
      char* allDown = getAllDown(allDownProp, getBitSel, parentForward);
      char* someDown = getSomeDown(someDownProp, getBitSel, parentForward);
      int numInSomeUp = 0;
      int numInSomeDown = 0;
      int numValuesTotal = 0;
      int numAssignedDown = getNumAssignedDown(numAssignedDownProp, getSel, parentForward);
      
      //If value on arc already has to be used elsewhere, arc cannot exist
      if ((allDown[byteIndex] & bitMask) ||
          (reverseInfoExists && (allUp[byteIndex] & bitMask))) {
         return false;
      }
      
      int i;
      for (i = 0; i < numBytes-4; i+=4) {
         numInSomeDown += __builtin_popcount(*(int*)&someDown[i]);
         if (reverseInfoExists) {
            numInSomeUp += __builtin_popcount(*(int*)&someUp[i]);
            numValuesTotal += __builtin_popcount(*(int*)&someUp[i] | *(int*)&someDown[i]);
         }
      }
      for (; i < numBytes; i++) {
         unsigned char wordDown = someDown[i];
         if (reverseInfoExists) {
            unsigned char wordUp = someUp[i];
            unsigned char joinedWord = wordUp | wordDown;
            numValuesTotal += _numBitsInByteLookup[(unsigned char)joinedWord];
            /*while (joinedWord) {
               numValuesTotal += joinedWord & 0x1;
               joinedWord >>= 1;
            }*/
            numInSomeUp += _numBitsInByteLookup[(unsigned char)wordUp];
            /*while (wordUp) {
               numInSomeUp += wordUp & 0x1;
               wordUp >>= 1;
            }*/
         }
         numInSomeDown += _numBitsInByteLookup[(unsigned char)wordDown];
         /*while (wordDown) {
            numInSomeDown += wordDown & 0x1;
            wordDown >>= 1;
         }*/
      }
      if (!(someDown[byteIndex] & bitMask)) {
         numInSomeDown += 1;
         if (reverseInfoExists && !(someUp[byteIndex] & bitMask)) {
            numInSomeUp += 1;
            numValuesTotal += 1;
         }
      } else if (reverseInfoExists && !(someUp[byteIndex] & bitMask)) {
         numInSomeUp += 1;
      }
      
      //If not enough values used (either from root to sink, from parent to sink, or from root to child), arc cannot exist
      if (reverseInfoExists) {
         if (numValuesTotal < numVariables) {
            return false;
         }
         if (numInSomeUp < numVariables - numAssignedDown) {
            return false;
         }
      }
      if (numInSomeDown < numAssignedDown+1) {
         return false;
      }
      return true;
   } copy];
   
   _forwardTransitionClosures[someDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [someDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            newState[firstByte + byteIndex] |= bitMask;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[allDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [allDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      bool foundOnlyValue = false;
      int foundValue;
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            if (!foundOnlyValue) {
               foundOnlyValue = true;
               foundValue = i;
            } else {
               return true;
            }
         }
      }
      if (foundOnlyValue) {
         int shiftedValue = foundValue - minDom;
         int byteIndex = shiftedValue >> 3;
         char bitMask = 0x1 << (shiftedValue & 0x7);
         newState[firstByte + byteIndex] |= bitMask;
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, forward) + 1, newState);
   } copy];
   _reverseTransitionClosures[someUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [someUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            newState[firstByte + byteIndex] |= bitMask;
         }
      }
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[allUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [allUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      bool foundOnlyValue = false;
      int foundValue;
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            if (!foundOnlyValue) {
               foundOnlyValue = true;
               foundValue = i;
            } else {
               return true;
            }
         }
      }
      if (foundOnlyValue) {
         int shiftedValue = foundValue - minDom;
         int byteIndex = shiftedValue >> 3;
         char bitMask = 0x1 << (shiftedValue & 0x7);
         newState[firstByte + byteIndex] |= bitMask;
      }
      return numArcs > 1;
   } copy];
   
   _forwardPropertyImpactCount[someDownIndex] = 1;
   _forwardPropertyImpactCount[allDownIndex] = 1;
   _forwardPropertyImpact[someDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[allDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[someDownIndex][0] = someDownIndex;
   _forwardPropertyImpact[allDownIndex][0] = allDownIndex;

   _reversePropertyImpactCount[someUpIndex] = 1;
   _reversePropertyImpactCount[allUpIndex] = 1;
   _reversePropertyImpact[someUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[allUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[someUpIndex][0] = someUpIndex;
   _reversePropertyImpact[allUpIndex][0] = allUpIndex;
   
   _forwardRelaxationClosures[someDownIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[someDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] | right[i];
      }
   } copy];
   _forwardRelaxationClosures[allDownIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[allDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] & right[i];
      }
   } copy];
   _forwardRelaxationClosures[numAssignedDownIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, left), newState);
   } copy];
   _reverseRelaxationClosures[someUpIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[someUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] | right[i];
      }
   } copy];
   _reverseRelaxationClosures[allUpIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[allUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] & right[i];
      }
   } copy];
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
        _candidateSplitValueClosure = [^(NSArray* candidate) {
           return -[candidate count];
        } copy];
     }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      // return ;
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int blockSize = domSize/4;
         int firstBlockMin = minDom;
         int secondBlockMin = firstBlockMin + blockSize;
         int thirdBlockMin = secondBlockMin + blockSize;
         int fourthBlockMin = thirdBlockMin + blockSize;
         
         int firstBlockSomeCount = 0;
         int firstBlockAllCount = 0;
         int secondBlockSomeCount = 0;
         int secondBlockAllCount = 0;
         int thirdBlockSomeCount = 0;
         int thirdBlockAllCount = 0;
         int fourthBlockSomeCount = 0;
         int fourthBlockAllCount = 0;
         
         char* allUp = getAllUp(allUpProp, getBitSel, reverse);
         char* someUp = getSomeUp(someUpProp, getBitSel, reverse);
         char* allDown = getAllDown(allDownProp, getBitSel, forward);
         char* someDown = getSomeDown(someDownProp, getBitSel, forward);
                           
         int i;
         for (i = firstBlockMin; i < secondBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask || allDown[byteIndex] & bitMask) {
               firstBlockAllCount++;
               firstBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               firstBlockSomeCount++;
            }
         }
         for (; i < thirdBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               secondBlockAllCount++;
               secondBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               secondBlockSomeCount++;
            }
         }
         for (; i < fourthBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               thirdBlockAllCount++;
               thirdBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               thirdBlockSomeCount++;
            }
         }
         for (; i <= maxDom; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               fourthBlockAllCount++;
               fourthBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               fourthBlockSomeCount++;
            }
         }
         
         return (firstBlockAllCount - firstBlockSomeCount > 2) +
            2 * (secondBlockAllCount - secondBlockSomeCount > 2) +
            4 * (thirdBlockAllCount - thirdBlockSomeCount > 2) +
            8 * (fourthBlockAllCount - fourthBlockSomeCount > 2);
      } copy];
   }
}
-(void) setAsImprovedDualDirectionalAllDifferent:(int)numVariables domain:(id<ORIntRange>)domain nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   
   int minDom = [domain low];
   int maxDom = [domain up];
   int domSize = maxDom - minDom + 1;
   int numBytes = ceil(domSize/8.0);
   int someDownIndex = 0, allDownIndex = 1, numInSomeDownIndex = 2, numAssignedDownIndex = 3,
       someUpIndex = 0, allUpIndex = 1, numInSomeUpIndex = 2,
       numInSomeCombinedIndex = 0;
   MDDPropertyDescriptor* someDownProp = _forwardStateProperties[someDownIndex];
   MDDPropertyDescriptor* allDownProp = _forwardStateProperties[allDownIndex];
   MDDPropertyDescriptor* numInSomeDownProp = _forwardStateProperties[numInSomeDownIndex];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedDownIndex];
   MDDPropertyDescriptor* someUpProp = _reverseStateProperties[someUpIndex];
   MDDPropertyDescriptor* allUpProp = _reverseStateProperties[allUpIndex];
   MDDPropertyDescriptor* numInSomeUpProp = _reverseStateProperties[numInSomeUpIndex];
   MDDPropertyDescriptor* numInSomeCombinedProp = _combinedStateProperties[numInSomeCombinedIndex];
   
   SEL getBitSel = @selector(getBitSequence:);
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetBitsPropIMP getSomeDown = (GetBitsPropIMP)[someDownProp methodForSelector:getBitSel];
   GetBitsPropIMP getAllDown = (GetBitsPropIMP)[allDownProp methodForSelector:getBitSel];
   GetPropIMP getNumInSomeDown = (GetPropIMP)[numInSomeDownProp methodForSelector:getSel];
   SetPropIMP setNumInSomeDown = (SetPropIMP)[numInSomeDownProp methodForSelector:setSel];
   GetPropIMP getNumAssignedDown = (GetPropIMP)[numAssignedDownProp methodForSelector:getSel];
   SetPropIMP setNumAssignedDown = (SetPropIMP)[numAssignedDownProp methodForSelector:setSel];
   GetBitsPropIMP getSomeUp = (GetBitsPropIMP)[someUpProp methodForSelector:getBitSel];
   GetBitsPropIMP getAllUp = (GetBitsPropIMP)[allUpProp methodForSelector:getBitSel];
   GetPropIMP getNumInSomeUp = (GetPropIMP)[numInSomeUpProp methodForSelector:getSel];
   SetPropIMP setNumInSomeUp = (SetPropIMP)[numInSomeUpProp methodForSelector:setSel];
   GetPropIMP getNumInSomeCombined = (GetPropIMP)[numInSomeCombinedProp methodForSelector:getSel];
   SetPropIMP setNumInSomeCombined = (SetPropIMP)[numInSomeCombinedProp methodForSelector:setSel];
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      bool reverseInfoExists = childReverse != nil;
      int shiftedValue = value - minDom;
      int byteIndex = shiftedValue >> 3;
      char bitMask = 0x1 << (shiftedValue & 0x7);
      char* allUp;
      char* someUp;
      if (reverseInfoExists) {
         allUp = getAllUp(allUpProp, getBitSel, childReverse);
         someUp = getSomeUp(someUpProp, getBitSel, childReverse);
      }
      char* allDown = getAllDown(allDownProp, getBitSel, parentForward);
      char* someDown = getSomeDown(someDownProp, getBitSel, parentForward);
      int numAssignedDown = getNumAssignedDown(numAssignedDownProp, getSel, parentForward);
      
      //If value on arc already has to be used elsewhere, arc cannot exist
      if ((allDown[byteIndex] & bitMask) ||
          (reverseInfoExists && (allUp[byteIndex] & bitMask))) {
         return false;
      }
      
      int numInSomeDown = getNumInSomeDown(numInSomeDownProp, getSel, parentForward);
      if (numInSomeDown + (!(someDown[byteIndex] & bitMask)) < numAssignedDown+1) {
         return false;
      } else if (reverseInfoExists) {
         int numInSomeUp = getNumAssignedDown(numInSomeUpProp, getSel, childReverse);
         if (numInSomeUp + (!(someUp[byteIndex] & bitMask)) < numVariables - numAssignedDown) {
            return false;
         }
      }
      return true;
   } copy];
   
   _forwardTransitionClosures[someDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [someDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            newState[firstByte + byteIndex] |= bitMask;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[allDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [allDownProp byteOffset];
      memcpy(newState + firstByte, forward + firstByte, numBytes);
      bool foundOnlyValue = false;
      int foundValue;
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            if (!foundOnlyValue) {
               foundOnlyValue = true;
               foundValue = i;
            } else {
               return true;
            }
         }
      }
      if (foundOnlyValue) {
         int shiftedValue = foundValue - minDom;
         int byteIndex = shiftedValue >> 3;
         char bitMask = 0x1 << (shiftedValue & 0x7);
         newState[firstByte + byteIndex] |= bitMask;
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numInSomeDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      int numInSomeDown = getNumInSomeDown(numInSomeDownProp, getSel, forward);
      size_t firstByte = [someDownProp byteOffset];
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (!(forward[firstByte + byteIndex] & bitMask)) {
               numInSomeDown++;
            }
         }
      }
      setNumInSomeDown(numInSomeDownProp, setSel, numInSomeDown, newState);
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, forward) + 1, newState);
   } copy];
   _reverseTransitionClosures[someUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [someUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            newState[firstByte + byteIndex] |= bitMask;
         }
      }
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[allUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      size_t firstByte = [allUpProp byteOffset];
      memcpy(newState + firstByte, reverse + firstByte, numBytes);
      bool foundOnlyValue = false;
      int foundValue;
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            if (!foundOnlyValue) {
               foundOnlyValue = true;
               foundValue = i;
            } else {
               return true;
            }
         }
      }
      if (foundOnlyValue) {
         int shiftedValue = foundValue - minDom;
         int byteIndex = shiftedValue >> 3;
         char bitMask = 0x1 << (shiftedValue & 0x7);
         newState[firstByte + byteIndex] |= bitMask;
      }
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[numInSomeUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDomIndex, int maxDomIndex) {
      int numInSomeUp = getNumInSomeUp(numInSomeUpProp, getSel, reverse);
      size_t firstByte = [someUpProp byteOffset];
      for (int i = minDomIndex; i <= maxDomIndex; i++) {
         if (valueSet[i]) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (!(reverse[firstByte + byteIndex] & bitMask)) {
               numInSomeUp++;
            }
         }
      }
      setNumInSomeUp(numInSomeUpProp, setSel, numInSomeUp, newState);
      return numArcs > 1;
   } copy];
   
   _forwardPropertyImpactCount[someDownIndex] = 2;
   _forwardPropertyImpactCount[allDownIndex] = 1;
   _forwardPropertyImpact[someDownIndex] = malloc(2 * sizeof(int));
   _forwardPropertyImpact[allDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[someDownIndex][0] = someDownIndex;
   _forwardPropertyImpact[someDownIndex][1] = numInSomeDownIndex;
   _forwardPropertyImpact[allDownIndex][0] = allDownIndex;

   _reversePropertyImpactCount[someUpIndex] = 2;
   _reversePropertyImpactCount[allUpIndex] = 1;
   _reversePropertyImpact[someUpIndex] = malloc(2 * sizeof(int));
   _reversePropertyImpact[allUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[someUpIndex][0] = someUpIndex;
   _reversePropertyImpact[someUpIndex][1] = numInSomeUpIndex;
   _reversePropertyImpact[allUpIndex][0] = allUpIndex;
   
   _forwardRelaxationClosures[someDownIndex] = [^(char* newState, char* left, char* right) {
      int numInSomeDown = 0;
      int firstByte = (int)[someDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] | right[i];
         numInSomeDown += _numBitsInByteLookup[(unsigned char)newState[i]];
      }
      setNumInSomeDown(numInSomeDownProp, setSel, numInSomeDown, newState);
   } copy];
   _forwardRelaxationClosures[allDownIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[allDownProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] & right[i];
      }
   } copy];
   _forwardRelaxationClosures[numInSomeDownIndex] = [^(char* newState, char* left, char* right) {
   } copy];
   _forwardRelaxationClosures[numAssignedDownIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, left), newState);
   } copy];
   _reverseRelaxationClosures[someUpIndex] = [^(char* newState, char* left, char* right) {
      int numInSomeUp = 0;
      int firstByte = (int)[someUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] | right[i];
         numInSomeUp += _numBitsInByteLookup[(unsigned char)newState[i]];
      }
      setNumInSomeUp(numInSomeUpProp, setSel, numInSomeUp, newState);
   } copy];
   _reverseRelaxationClosures[allUpIndex] = [^(char* newState, char* left, char* right) {
      int firstByte = (int)[allUpProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = left[i] & right[i];
      }
   } copy];
   _reverseRelaxationClosures[numInSomeUpIndex] = [^(char* newState, char* left, char* right) {
   } copy];
   
   _updatePropertyClosures[numInSomeCombinedIndex] = [^(char* combined, char* forward, char* reverse) {
      if (reverse != nil) {
         int numValuesTotal = 0;
         int downFirstByte = (int)[someDownProp byteOffset];
         int upFirstByte = (int)[someUpProp byteOffset];
         for (int i = 0; i < numBytes; i++) {
            unsigned char joinedWord = forward[downFirstByte + i] | reverse[upFirstByte + i];
            numValuesTotal += _numBitsInByteLookup[joinedWord];
         }
         setNumInSomeCombined(numInSomeCombinedProp, setSel, numValuesTotal, combined);
      }
   } copy];
   
   _stateExistsClosure = [^(char* forward, char* reverse, char* combined) {
      int numInSomeDown = getNumInSomeDown(numInSomeDownProp, getSel, forward);
      int numInSomeUp = getNumInSomeUp(numInSomeUpProp, getSel, reverse);
      int numInSomeCombined = getNumInSomeCombined(numInSomeCombinedProp, getSel, combined);
      int numAssignedDown = getNumAssignedDown(numAssignedDownProp, getSel, forward);
      return numInSomeDown >= numAssignedDown &&
             numInSomeUp >= (numVariables - numAssignedDown) &&
             numInSomeCombined >= numVariables;
   } copy];
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
        _candidateSplitValueClosure = [^(NSArray* candidate) {
           return -[candidate count];
        } copy];
     }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      // return ;
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int blockSize = domSize/4;
         int firstBlockMin = minDom;
         int secondBlockMin = firstBlockMin + blockSize;
         int thirdBlockMin = secondBlockMin + blockSize;
         int fourthBlockMin = thirdBlockMin + blockSize;
         
         int firstBlockSomeCount = 0;
         int firstBlockAllCount = 0;
         int secondBlockSomeCount = 0;
         int secondBlockAllCount = 0;
         int thirdBlockSomeCount = 0;
         int thirdBlockAllCount = 0;
         int fourthBlockSomeCount = 0;
         int fourthBlockAllCount = 0;
         
         char* allUp = getAllUp(allUpProp, getBitSel, reverse);
         char* someUp = getSomeUp(someUpProp, getBitSel, reverse);
         char* allDown = getAllDown(allDownProp, getBitSel, forward);
         char* someDown = getSomeDown(someDownProp, getBitSel, forward);
                           
         int i;
         for (i = firstBlockMin; i < secondBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask || allDown[byteIndex] & bitMask) {
               firstBlockAllCount++;
               firstBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               firstBlockSomeCount++;
            }
         }
         for (; i < thirdBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               secondBlockAllCount++;
               secondBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               secondBlockSomeCount++;
            }
         }
         for (; i < fourthBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               thirdBlockAllCount++;
               thirdBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               thirdBlockSomeCount++;
            }
         }
         for (; i <= maxDom; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               fourthBlockAllCount++;
               fourthBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               fourthBlockSomeCount++;
            }
         }
         
         return (firstBlockAllCount - firstBlockSomeCount > 2) +
            2 * (secondBlockAllCount - secondBlockSomeCount > 2) +
            4 * (thirdBlockAllCount - thirdBlockSomeCount > 2) +
            8 * (fourthBlockAllCount - fourthBlockSomeCount > 2);
      } copy];
   } else if (stateEquivalenceMode == 2) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int blockSize = domSize/2;
         int firstBlockMin = minDom;
         int secondBlockMin = firstBlockMin + blockSize;
         
         int firstBlockSomeCount = 0;
         int firstBlockAllCount = 0;
         int secondBlockSomeCount = 0;
         int secondBlockAllCount = 0;
         
         char* allUp = getAllUp(allUpProp, getBitSel, reverse);
         char* someUp = getSomeUp(someUpProp, getBitSel, reverse);
         char* allDown = getAllDown(allDownProp, getBitSel, forward);
         char* someDown = getSomeDown(someDownProp, getBitSel, forward);
                           
         int i;
         for (i = firstBlockMin; i < secondBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask || allDown[byteIndex] & bitMask) {
               firstBlockAllCount++;
               firstBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               firstBlockSomeCount++;
            }
         }
         for (; i <= maxDom; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               secondBlockAllCount++;
               secondBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               secondBlockSomeCount++;
            }
         }
         
         return (firstBlockAllCount - firstBlockSomeCount > 2) +
            2 * (secondBlockAllCount - secondBlockSomeCount > 2);
      } copy];
   } else if (stateEquivalenceMode == 3) {
      _approximateEquivalenceClosure = [^(char* forward, char* reverse) {
         int numInSomeDown = getNumInSomeDown(numInSomeDownProp, getSel, forward);
         int numAssignedDown = getNumAssignedDown(numAssignedDownProp, getSel, forward);
         if (numInSomeDown - numAssignedDown > 4) {
            return 0;
         }
         int blockSize = domSize/2;
         int firstBlockMin = minDom;
         int secondBlockMin = firstBlockMin + blockSize;
         
         int firstBlockSomeCount = 0;
         int firstBlockAllCount = 0;
         int secondBlockSomeCount = 0;
         int secondBlockAllCount = 0;
         
         char* allUp = getAllUp(allUpProp, getBitSel, reverse);
         char* someUp = getSomeUp(someUpProp, getBitSel, reverse);
         char* allDown = getAllDown(allDownProp, getBitSel, forward);
         char* someDown = getSomeDown(someDownProp, getBitSel, forward);
                           
         int i;
         for (i = firstBlockMin; i < secondBlockMin; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask || allDown[byteIndex] & bitMask) {
               firstBlockAllCount++;
               firstBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               firstBlockSomeCount++;
            }
         }
         for (; i <= maxDom; i++) {
            int shiftedValue = i - minDom;
            int byteIndex = shiftedValue >> 3;
            char bitMask = 0x1 << (shiftedValue & 0x7);
            if (allUp[byteIndex] & bitMask) {
               secondBlockAllCount++;
               secondBlockSomeCount++;
            } else if (someUp[byteIndex] & bitMask || someDown[byteIndex] & bitMask) {
               secondBlockSomeCount++;
            }
         }
         
         return 1 + (firstBlockAllCount - firstBlockSomeCount > 2) +
            2 * (secondBlockAllCount - secondBlockSomeCount > 2);
      } copy];
   }
}
-(void) setAsDualDirectionalSum:(int)numVars maxDom:(int)maxDom weights:(int*)weights lower:(int)lb upper:(int)ub nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   int minDownIndex = 0, maxDownIndex = 1, numAssignedDownIndex = 2,
       minUpIndex = 0, maxUpIndex = 1, numAssignedUpIndex = 2;
   MDDPropertyDescriptor* minDownProp = _forwardStateProperties[minDownIndex];
   MDDPropertyDescriptor* maxDownProp = _forwardStateProperties[maxDownIndex];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedDownIndex];
   MDDPropertyDescriptor* minUpProp = _reverseStateProperties[minUpIndex];
   MDDPropertyDescriptor* maxUpProp = _reverseStateProperties[maxUpIndex];
   MDDPropertyDescriptor* numAssignedUpProp = _reverseStateProperties[numAssignedUpIndex];
   
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetPropIMP getMinDown = (GetPropIMP)[minDownProp methodForSelector:getSel];
   SetPropIMP setMinDown = (SetPropIMP)[minDownProp methodForSelector:setSel];
   GetPropIMP getMaxDown = (GetPropIMP)[maxDownProp methodForSelector:getSel];
   SetPropIMP setMaxDown = (SetPropIMP)[maxDownProp methodForSelector:setSel];
   GetPropIMP getNumAssignedDown = (GetPropIMP)[numAssignedDownProp methodForSelector:getSel];
   SetPropIMP setNumAssignedDown = (SetPropIMP)[numAssignedDownProp methodForSelector:setSel];
   GetPropIMP getMinUp = (GetPropIMP)[minUpProp methodForSelector:getSel];
   SetPropIMP setMinUp = (SetPropIMP)[minUpProp methodForSelector:setSel];
   GetPropIMP getMaxUp = (GetPropIMP)[maxUpProp methodForSelector:getSel];
   SetPropIMP setMaxUp = (SetPropIMP)[maxUpProp methodForSelector:setSel];
   GetPropIMP getNumAssignedUp = (GetPropIMP)[numAssignedUpProp methodForSelector:getSel];
   SetPropIMP setNumAssignedUp = (SetPropIMP)[numAssignedUpProp methodForSelector:setSel];
   
   //int* noChildMinUpByLayer = malloc(numVars * sizeof(int));
   int* noChildMaxUpByLayer = malloc(numVars * sizeof(int));
   //noChildMinUpByLayer[numVars-1] = 0;
   noChildMaxUpByLayer[numVars-1] = 0;
   for (int i = numVars-2; i >= 0; i--) {
      //noChildMinUpByLayer[i] = noChildMinUpByLayer[i+1] + weights[i+1]*0;
      noChildMaxUpByLayer[i] = noChildMaxUpByLayer[i+1] + weights[i+1]*maxDom;
   }
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      int numAssigned = getNumAssignedDown(numAssignedDownProp, getSel, parentForward);
      int arcWeight = value * weights[numAssigned];
      if (childReverse != nil) {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight + getMinUp(minUpProp, getSel, childReverse) <= ub &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + getMaxUp(maxUpProp, getSel, childReverse) >= lb;
      } else {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight <= ub &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + noChildMaxUpByLayer[numAssigned] >= lb;
      }
   } copy];
   
   _forwardTransitionClosures[minDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            setMinDown(minDownProp, setSel, getMinDown(minDownProp, getSel, forward) + weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)] * i, newState);
            break;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[maxDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      for (int i = maxDom; i >= minDom; i--) {
         if (valueSet[i]) {
            setMaxDown(maxDownProp, setSel, getMaxDown(maxDownProp, getSel, forward) + weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)] * i, newState);
            break;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, forward) + 1, newState);
      return false;
   } copy];
   _reverseTransitionClosures[minUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int minValue = maxDom;
      int maxValue = minDom;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            minValue = i;
            break;
         }
      }
      for (int i = maxDom; i >= minValue; i--) {
         if (valueSet[i]) {
            maxValue = i;
            break;
         }
      }
      int weight = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      int minWeight = min(minValue * weight, maxValue * weight);
      setMinUp(minUpProp, setSel, getMinUp(minUpProp, getSel, reverse) + minWeight, newState);
      
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[maxUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int minValue = maxDom;
      int maxValue = minDom;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            minValue = i;
            break;
         }
      }
      for (int i = maxDom; i >= minValue; i--) {
         if (valueSet[i]) {
            maxValue = i;
            break;
         }
      }
      int weight = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      int maxWeight = max(minValue * weight, maxValue * weight);
      setMaxUp(maxUpProp, setSel, getMaxUp(maxUpProp, getSel, reverse) + maxWeight, newState);
      
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[numAssignedUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, reverse) + 1, newState);
      return false;
   } copy];
   
   _forwardPropertyImpactCount[minDownIndex] = 1;
   _forwardPropertyImpactCount[maxDownIndex] = 1;
   _forwardPropertyImpact[minDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[maxDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minDownIndex][0] = minDownIndex;
   _forwardPropertyImpact[maxDownIndex][0] = maxDownIndex;

   _reversePropertyImpactCount[minUpIndex] = 1;
   _reversePropertyImpactCount[maxUpIndex] = 1;
   _reversePropertyImpact[minUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[maxUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minUpIndex][0] = minUpIndex;
   _reversePropertyImpact[maxUpIndex][0] = maxUpIndex;
   
   _forwardRelaxationClosures[minDownIndex] = [^(char* newState, char* left, char* right) {
      setMinDown(minDownProp, setSel, min(getMinDown(minDownProp, getSel, left), getMinDown(minDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[maxDownIndex] = [^(char* newState, char* left, char* right) {
      setMaxDown(maxDownProp, setSel, max(getMaxDown(maxDownProp, getSel, left), getMaxDown(maxDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[numAssignedDownIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, left), newState);
   } copy];
   _reverseRelaxationClosures[minUpIndex] = [^(char* newState, char* left, char* right) {
      setMinUp(minUpProp, setSel, min(getMinUp(minUpProp, getSel, left), getMinUp(minUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[maxUpIndex] = [^(char* newState, char* left, char* right) {
      setMaxUp(maxUpProp, setSel, max(getMaxUp(maxUpProp, getSel, left), getMaxUp(maxUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[numAssignedUpIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, left), newState);
   } copy];
}
-(void) setAsDualDirectionalSum:(int)numVars maxDom:(int)maxDom weights:(int*)weights equal:(id<ORIntVar>)equal nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   int minDownIndex = 0, maxDownIndex = 1, numAssignedDownIndex = 2,
       minUpIndex = 0, maxUpIndex = 1, numAssignedUpIndex = 2;
   MDDPropertyDescriptor* minDownProp = _forwardStateProperties[minDownIndex];
   MDDPropertyDescriptor* maxDownProp = _forwardStateProperties[maxDownIndex];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedDownIndex];
   MDDPropertyDescriptor* minUpProp = _reverseStateProperties[minUpIndex];
   MDDPropertyDescriptor* maxUpProp = _reverseStateProperties[maxUpIndex];
   MDDPropertyDescriptor* numAssignedUpProp = _reverseStateProperties[numAssignedUpIndex];
   
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetPropIMP getMinDown = (GetPropIMP)[minDownProp methodForSelector:getSel];
   SetPropIMP setMinDown = (SetPropIMP)[minDownProp methodForSelector:setSel];
   GetPropIMP getMaxDown = (GetPropIMP)[maxDownProp methodForSelector:getSel];
   SetPropIMP setMaxDown = (SetPropIMP)[maxDownProp methodForSelector:setSel];
   GetPropIMP getNumAssignedDown = (GetPropIMP)[numAssignedDownProp methodForSelector:getSel];
   SetPropIMP setNumAssignedDown = (SetPropIMP)[numAssignedDownProp methodForSelector:setSel];
   GetPropIMP getMinUp = (GetPropIMP)[minUpProp methodForSelector:getSel];
   SetPropIMP setMinUp = (SetPropIMP)[minUpProp methodForSelector:setSel];
   GetPropIMP getMaxUp = (GetPropIMP)[maxUpProp methodForSelector:getSel];
   SetPropIMP setMaxUp = (SetPropIMP)[maxUpProp methodForSelector:setSel];
   GetPropIMP getNumAssignedUp = (GetPropIMP)[numAssignedUpProp methodForSelector:getSel];
   SetPropIMP setNumAssignedUp = (SetPropIMP)[numAssignedUpProp methodForSelector:setSel];
   
   //int* noChildMinUpByLayer = malloc(numVars * sizeof(int));
   int* noChildMaxUpByLayer = malloc(numVars * sizeof(int));
   //noChildMinUpByLayer[numVars-1] = 0;
   noChildMaxUpByLayer[numVars-1] = 0;
   for (int i = numVars-2; i >= 0; i--) {
      //noChildMinUpByLayer[i] = noChildMinUpByLayer[i+1] + weights[i+1]*0;
      noChildMaxUpByLayer[i] = noChildMaxUpByLayer[i+1] + weights[i+1]*maxDom;
   }
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      int numAssigned = getNumAssignedDown(numAssignedDownProp, getSel, parentForward);
      int arcWeight = value * weights[numAssigned];
      if (childReverse != nil) {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight + getMinUp(minUpProp, getSel, childReverse) <= [equal max] &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + getMaxUp(maxUpProp, getSel, childReverse) >= [equal min];
      } else {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight <= [equal max] &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + noChildMaxUpByLayer[numAssigned] >= [equal min];
      }
   } copy];
   
   _forwardTransitionClosures[minDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            setMinDown(minDownProp, setSel, getMinDown(minDownProp, getSel, forward) + weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)] * i, newState);
            break;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[maxDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      for (int i = maxDom; i >= minDom; i--) {
         if (valueSet[i]) {
            setMaxDown(maxDownProp, setSel, getMaxDown(maxDownProp, getSel, forward) + weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)] * i, newState);
            break;
         }
      }
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, forward) + 1, newState);
   } copy];
   _reverseTransitionClosures[minUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int minValue = maxDom;
      int maxValue = minDom;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            minValue = i;
            break;
         }
      }
      for (int i = maxDom; i >= minValue; i--) {
         if (valueSet[i]) {
            maxValue = i;
            break;
         }
      }
      int weight = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      int minWeight = min(minValue * weight, maxValue * weight);
      setMinUp(minUpProp, setSel, getMinUp(minUpProp, getSel, reverse) + minWeight, newState);
      
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[maxUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int minValue = maxDom;
      int maxValue = minDom;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            minValue = i;
            break;
         }
      }
      for (int i = maxDom; i >= minValue; i--) {
         if (valueSet[i]) {
            maxValue = i;
            break;
         }
      }
      int weight = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      int maxWeight = max(minValue * weight, maxValue * weight);
      setMaxUp(maxUpProp, setSel, getMaxUp(maxUpProp, getSel, reverse) + maxWeight, newState);
      
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[numAssignedUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, reverse) + 1, newState);
      return false;
   } copy];
   
   _forwardPropertyImpactCount[minDownIndex] = 1;
   _forwardPropertyImpactCount[maxDownIndex] = 1;
   _forwardPropertyImpact[minDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[maxDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minDownIndex][0] = minDownIndex;
   _forwardPropertyImpact[maxDownIndex][0] = maxDownIndex;

   _reversePropertyImpactCount[minUpIndex] = 1;
   _reversePropertyImpactCount[maxUpIndex] = 1;
   _reversePropertyImpact[minUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[maxUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minUpIndex][0] = minUpIndex;
   _reversePropertyImpact[maxUpIndex][0] = maxUpIndex;
   
   _forwardRelaxationClosures[minDownIndex] = [^(char* newState, char* left, char* right) {
      setMinDown(minDownProp, setSel, min(getMinDown(minDownProp, getSel, left), getMinDown(minDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[maxDownIndex] = [^(char* newState, char* left, char* right) {
      setMaxDown(maxDownProp, setSel, max(getMaxDown(maxDownProp, getSel, left), getMaxDown(maxDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[numAssignedDownIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, left), newState);
   } copy];
   _reverseRelaxationClosures[minUpIndex] = [^(char* newState, char* left, char* right) {
      setMinUp(minUpProp, setSel, min(getMinUp(minUpProp, getSel, left), getMinUp(minUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[maxUpIndex] = [^(char* newState, char* left, char* right) {
      setMaxUp(maxUpProp, setSel, max(getMaxUp(maxUpProp, getSel, left), getMaxUp(maxUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[numAssignedUpIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, left), newState);
   } copy];
   
   _fixpointVar = equal;
   _fixpointMin = [^(char* sink) {
      return getMinDown(minDownProp, getSel, sink);
   } copy];
   _fixpointMax = [^(char* sink) {
      return getMaxDown(maxDownProp, getSel, sink);
   } copy];
}
-(void) setAsDualDirectionalSum:(int)numVars maxDom:(int)maxDom weightMatrix:(int**)weights equal:(id<ORIntVar>)equal nodePriorityMode:(int)nodePriorityMode candidatePriorityMode:(int)candidatePriorityMode stateEquivalenceMode:(int)stateEquivalenceMode {
   _dualDirectional = true;
   int minDownIndex = 0, maxDownIndex = 1, numAssignedDownIndex = 2,
       minUpIndex = 0, maxUpIndex = 1, numAssignedUpIndex = 2;
   MDDPropertyDescriptor* minDownProp = _forwardStateProperties[minDownIndex];
   MDDPropertyDescriptor* maxDownProp = _forwardStateProperties[maxDownIndex];
   MDDPropertyDescriptor* numAssignedDownProp = _forwardStateProperties[numAssignedDownIndex];
   MDDPropertyDescriptor* minUpProp = _reverseStateProperties[minUpIndex];
   MDDPropertyDescriptor* maxUpProp = _reverseStateProperties[maxUpIndex];
   MDDPropertyDescriptor* numAssignedUpProp = _reverseStateProperties[numAssignedUpIndex];
   
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   GetPropIMP getMinDown = (GetPropIMP)[minDownProp methodForSelector:getSel];
   SetPropIMP setMinDown = (SetPropIMP)[minDownProp methodForSelector:setSel];
   GetPropIMP getMaxDown = (GetPropIMP)[maxDownProp methodForSelector:getSel];
   SetPropIMP setMaxDown = (SetPropIMP)[maxDownProp methodForSelector:setSel];
   GetPropIMP getNumAssignedDown = (GetPropIMP)[numAssignedDownProp methodForSelector:getSel];
   SetPropIMP setNumAssignedDown = (SetPropIMP)[numAssignedDownProp methodForSelector:setSel];
   GetPropIMP getMinUp = (GetPropIMP)[minUpProp methodForSelector:getSel];
   SetPropIMP setMinUp = (SetPropIMP)[minUpProp methodForSelector:setSel];
   GetPropIMP getMaxUp = (GetPropIMP)[maxUpProp methodForSelector:getSel];
   SetPropIMP setMaxUp = (SetPropIMP)[maxUpProp methodForSelector:setSel];
   GetPropIMP getNumAssignedUp = (GetPropIMP)[numAssignedUpProp methodForSelector:getSel];
   SetPropIMP setNumAssignedUp = (SetPropIMP)[numAssignedUpProp methodForSelector:setSel];
   
   int* noChildMinUpByLayer = malloc(numVars * sizeof(int));
   int* noChildMaxUpByLayer = malloc(numVars * sizeof(int));
   noChildMinUpByLayer[numVars-1] = 0;
   noChildMaxUpByLayer[numVars-1] = 0;
   for (int i = numVars-2; i >= 0; i--) {
      int layerMin = INT_MAX;
      int layerMax = INT_MIN;
      for (int j = 0; j <= maxDom; j++) {
         if (weights[i+1][j] < layerMin) {
            layerMin = weights[i+1][j];
         }
         if (weights[i+1][j] > layerMax) {
            layerMax = weights[i+1][j];
         }
      }
      noChildMinUpByLayer[i] = noChildMinUpByLayer[i+1] + layerMin;
      noChildMaxUpByLayer[i] = noChildMaxUpByLayer[i+1] + layerMax;
   }
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value, ORInt objectiveMin, ORInt objectiveMax) {
      int numAssigned = getNumAssignedDown(numAssignedDownProp, getSel, parentForward);
      int arcWeight = weights[numAssigned][value];
      if (childReverse != nil) {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight + getMinUp(minUpProp, getSel, childReverse) <= objectiveMax &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + getMaxUp(maxUpProp, getSel, childReverse) >= objectiveMin;
      } else {
         return getMinDown(minDownProp, getSel, parentForward) + arcWeight <= objectiveMax &&
                getMaxDown(maxDownProp, getSel, parentForward) + arcWeight + noChildMaxUpByLayer[numAssigned] >= objectiveMin;
      }
   } copy];
   
   _forwardTransitionClosures[minDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int* weightsForLayer = weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)];
      int minWeight = INT_MAX;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            if (minWeight > weightsForLayer[i]) {
               minWeight = weightsForLayer[i];
            }
         }
      }
      setMinDown(minDownProp, setSel, getMinDown(minDownProp, getSel, forward) + minWeight, newState);
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[maxDownIndex] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int* weightsForLayer = weights[getNumAssignedDown(numAssignedDownProp, getSel, forward)];
      int maxWeight = INT_MIN;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            if (maxWeight < weightsForLayer[i]) {
               maxWeight = weightsForLayer[i];
            }
         }
      }
      setMaxDown(maxDownProp, setSel, getMaxDown(maxDownProp, getSel, forward) + maxWeight, newState);
      return numArcs > 1;
   } copy];
   _forwardTransitionClosures[numAssignedDownIndex] = [^(char* newState, char* forward, char* combined, ORInt value) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, forward) + 1, newState);
      return false;
   } copy];
   _reverseTransitionClosures[minUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int minWeight = INT_MAX;
      int* weightsByValue = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            minWeight = min(minWeight, weightsByValue[i]);
         }
      }
      setMinUp(minUpProp, setSel, getMinUp(minUpProp, getSel, reverse) + minWeight, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[maxUpIndex] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      int maxWeight = INT_MIN;
      int* weightsByValue = weights[numVars - getNumAssignedUp(numAssignedUpProp, getSel, reverse)-1];
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i]) {
            maxWeight = max(maxWeight, weightsByValue[i]);
         }
      }
      setMaxUp(maxUpProp, setSel, getMaxUp(maxUpProp, getSel, reverse) + maxWeight, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[numAssignedUpIndex] = [^(char* newState, char* reverse, char* combined, ORInt value) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, reverse) + 1, newState);
      return false;
   } copy];
   
   _forwardPropertyImpactCount[minDownIndex] = 1;
   _forwardPropertyImpactCount[maxDownIndex] = 1;
   _forwardPropertyImpact[minDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[maxDownIndex] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minDownIndex][0] = minDownIndex;
   _forwardPropertyImpact[maxDownIndex][0] = maxDownIndex;

   _reversePropertyImpactCount[minUpIndex] = 1;
   _reversePropertyImpactCount[maxUpIndex] = 1;
   _reversePropertyImpact[minUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[maxUpIndex] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minUpIndex][0] = minUpIndex;
   _reversePropertyImpact[maxUpIndex][0] = maxUpIndex;
   
   _forwardRelaxationClosures[minDownIndex] = [^(char* newState, char* left, char* right) {
      setMinDown(minDownProp, setSel, min(getMinDown(minDownProp, getSel, left), getMinDown(minDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[maxDownIndex] = [^(char* newState, char* left, char* right) {
      setMaxDown(maxDownProp, setSel, max(getMaxDown(maxDownProp, getSel, left), getMaxDown(maxDownProp, getSel, right)), newState);
   } copy];
   _forwardRelaxationClosures[numAssignedDownIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedDown(numAssignedDownProp, setSel, getNumAssignedDown(numAssignedDownProp, getSel, left), newState);
   } copy];
   _reverseRelaxationClosures[minUpIndex] = [^(char* newState, char* left, char* right) {
      setMinUp(minUpProp, setSel, min(getMinUp(minUpProp, getSel, left), getMinUp(minUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[maxUpIndex] = [^(char* newState, char* left, char* right) {
      setMaxUp(maxUpProp, setSel, max(getMaxUp(maxUpProp, getSel, left), getMaxUp(maxUpProp, getSel, right)), newState);
   } copy];
   _reverseRelaxationClosures[numAssignedUpIndex] = [^(char* newState, char* left, char* right) {
      setNumAssignedUp(numAssignedUpProp, setSel, getNumAssignedUp(numAssignedUpProp, getSel, left), newState);
   } copy];
   
   
   if (nodePriorityMode == 0) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node indexOnLayer];
      } copy];
   } else  if (nodePriorityMode == 1) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return [node numParents];
      } copy];
   } else if (nodePriorityMode == 2) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return -[node numParents];
      } copy];
   } else if (nodePriorityMode == 3) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return getMinDown(minDownProp, getSel, forward);
      } copy];
   } else if (nodePriorityMode == 4) {
      _nodeSplitValueClosure = [^(char* forward, char* reverse, char* combined, MDDNode* node) {
         return getMaxDown(maxDownProp, getSel, forward);
      } copy];
   }
   
   if (candidatePriorityMode == 0) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [[(MDDArc*)[candidate firstObject] parent] indexOnLayer];
      } copy];
   } else if (candidatePriorityMode == 1) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
         return [candidate count];
      } copy];
   } else if (candidatePriorityMode == 2) {
      _candidateSplitValueClosure = [^(NSArray* candidate) {
        return -[candidate count];
     } copy];
   }
   
   if (stateEquivalenceMode == 0) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      //   return ;
      //} copy];
   } else if (stateEquivalenceMode == 1) {
      //_approximateEquivalenceClosure = [^(char* forward, char* reverse) {
      //   return ;
      //} copy];
   }
   
   _fixpointVar = equal;
   _fixpointMin = [^(char* sink) {
      return getMinDown(minDownProp, getSel, sink);
   } copy];
   _fixpointMax = [^(char* sink) {
      return getMaxDown(maxDownProp, getSel, sink);
   } copy];
}

-(void)setAsDualDirectionalSequence:(id<ORIntRange>)range numVars:(int)numVars length:(int)length lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values {
   _dualDirectional = true;
   ORInt minDom = [range low];
   ORInt domSize = [range size];
   int minValue = [values min];
   int maxValue = [values max];
   int numValues = [values size];
   
   int minForward = 0, maxForward = 1, ancestorMinWindow = 2, ancestorMaxWindow = 3, numAssigned = 4;
   int minReverse = 0, maxReverse = 1, descendentMinWindow = 2, descendentMaxWindow = 3;
   int minCombined = 0, maxCombined = 1;
   
   MDDPropertyDescriptor* minForwardProp = _forwardStateProperties[minForward];
   MDDPropertyDescriptor* maxForwardProp = _forwardStateProperties[maxForward];
   MDDPWindowShort* ancestorMinWindowProp = (MDDPWindowShort*)_forwardStateProperties[ancestorMinWindow];
   MDDPWindowShort* ancestorMaxWindowProp = (MDDPWindowShort*)_forwardStateProperties[ancestorMaxWindow];
   MDDPropertyDescriptor* numAssignedProp = _forwardStateProperties[numAssigned];
   
   MDDPropertyDescriptor* minReverseProp = _reverseStateProperties[minReverse];
   MDDPropertyDescriptor* maxReverseProp = _reverseStateProperties[maxReverse];
   MDDPWindowShort* descendentMinWindowProp = (MDDPWindowShort*)_reverseStateProperties[descendentMinWindow];
   MDDPWindowShort* descendentMaxWindowProp = (MDDPWindowShort*)_reverseStateProperties[descendentMaxWindow];
   
   MDDPropertyDescriptor* minCombinedProp = _combinedStateProperties[minCombined];
   MDDPropertyDescriptor* maxCombinedProp = _combinedStateProperties[maxCombined];
   
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   
   GetPropIMP getMinForward = (GetPropIMP)[minForwardProp methodForSelector:getSel];
   SetPropIMP setMinForward = (SetPropIMP)[minForwardProp methodForSelector:setSel];
   GetPropIMP getMaxForward = (GetPropIMP)[maxForwardProp methodForSelector:getSel];
   SetPropIMP setMaxForward = (SetPropIMP)[maxForwardProp methodForSelector:setSel];
   
   GetPropIMP getNumAssignedForward = (GetPropIMP)[numAssignedProp methodForSelector:getSel];
   SetPropIMP setNumAssignedForward = (SetPropIMP)[numAssignedProp methodForSelector:setSel];
   
   GetPropIMP getMinReverse = (GetPropIMP)[minReverseProp methodForSelector:getSel];
   SetPropIMP setMinReverse = (SetPropIMP)[minReverseProp methodForSelector:setSel];
   GetPropIMP getMaxReverse = (GetPropIMP)[maxReverseProp methodForSelector:getSel];
   SetPropIMP setMaxReverse = (SetPropIMP)[maxReverseProp methodForSelector:setSel];
   
   GetPropIMP getMinCombined = (GetPropIMP)[minCombinedProp methodForSelector:getSel];
   SetPropIMP setMinCombined = (SetPropIMP)[minCombinedProp methodForSelector:setSel];
   GetPropIMP getMaxCombined = (GetPropIMP)[maxCombinedProp methodForSelector:getSel];
   SetPropIMP setMaxCombined = (SetPropIMP)[maxCombinedProp methodForSelector:setSel];
   
   bool* valueInSetLookup = calloc(domSize, sizeof(bool));
   valueInSetLookup -= minDom;
   [values enumerateWithBlock:^(ORInt value) {
      valueInSetLookup[value] = true;
   }];
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      int valueInSet = (value >= minValue && value <= maxValue && valueInSetLookup[value]);
      int numAssignedForward = getNumAssignedForward(numAssignedProp, getSel, parentForward);
      int parentMin;
      int parentMax;
      if (parentCombined == nil) {
         parentMin = getMinForward(minForwardProp, getSel, parentForward);
         parentMax = getMaxForward(maxForwardProp, getSel, parentForward);
      } else {
         parentMin = getMinCombined(minCombinedProp, getSel, parentCombined);
         parentMax = getMaxCombined(maxCombinedProp, getSel, parentCombined);
      }
      if (!(numAssignedForward + 1 < length ||
               (parentMax - [ancestorMinWindowProp get:parentForward at:length-2] + valueInSet >= lb &&
                parentMin - [ancestorMaxWindowProp get:parentForward at:length-2] + valueInSet <= ub))) {
         return false;
      }
      if (childReverse != nil) {
         int childMin = getMinCombined(minCombinedProp, getSel, childCombined);
         int childMax = getMaxCombined(maxCombinedProp, getSel, childCombined);
         return parentMin + valueInSet <= childMax &&
                parentMax + valueInSet >= childMin &&
               (numVars - numAssignedForward <= length ||
                ([descendentMinWindowProp get:childReverse at:length-2] - childMax + valueInSet <= ub &&
                 [descendentMaxWindowProp get:childReverse at:length-2] - childMin + valueInSet >= lb));
         
      }
      return true;
   } copy];
   
   _forwardTransitionClosures[minForward] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      }
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               valueInSome = true;
            } else {
               valueInAll = false;
            }
            if (valueInSome && !valueInAll) {
               break;
            }
         }
      }
      if (combined == nil) {
         setMinForward(minForwardProp, setSel, getMinForward(minForwardProp, getSel, forward) + valueInAll, newState);
      } else {
         setMinForward(minForwardProp, setSel, getMinCombined(minCombinedProp, getSel, combined) + valueInAll, newState);
      }
      return valueInSome && !valueInAll;
   } copy];
   _forwardTransitionClosures[maxForward] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      }
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               valueInSome = true;
            } else {
               valueInAll = false;
            }
            if (valueInSome && !valueInAll) {
               break;
            }
         }
      }
      if (combined == nil) {
         setMaxForward(maxForwardProp, setSel, getMaxForward(maxForwardProp, getSel, forward) + valueInSome, newState);
      } else {
         setMaxForward(maxForwardProp, setSel, getMaxCombined(maxCombinedProp, getSel, combined) + valueInSome, newState);
      }
      return valueInSome && !valueInAll;
   } copy];
   _forwardTransitionClosures[ancestorMinWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [ancestorMinWindowProp set:forward forState:newState slideBy:1];
      if (combined == nil) {
         [ancestorMinWindowProp set:getMinForward(minForwardProp, getSel, forward) forState:newState at:0];
      } else {
         [ancestorMinWindowProp set:getMinCombined(minCombinedProp, getSel, combined) forState:newState at:0];
      }
      return false;
   } copy];
   _forwardTransitionClosures[ancestorMaxWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [ancestorMaxWindowProp set:forward forState:newState slideBy:1];
      if (combined == nil) {
         [ancestorMaxWindowProp set:getMaxForward(maxForwardProp, getSel, forward) forState:newState at:0];
      } else {
         [ancestorMaxWindowProp set:getMaxCombined(maxCombinedProp, getSel, combined) forState:newState at:0];
      }
      return false;
   } copy];
   _forwardTransitionClosures[numAssigned] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedForward(numAssignedProp, setSel, getNumAssignedForward(numAssignedProp, getSel, forward) + 1, newState);
   } copy];
   
   _reverseTransitionClosures[minReverse] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i] && i >= minValue && i <= maxValue && valueInSetLookup[i]) {
            valueInSome = true;
            break;
         }
      }
      setMinReverse(minReverseProp, setSel, getMinCombined(minCombinedProp, getSel, combined) - valueInSome, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[maxReverse] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      } else {
         for (int i = minDom; i <= maxDom; i++) {
            if (valueSet[i] && !(i >= minValue && i <= maxValue && valueInSetLookup[i])) {
               valueInAll = false;
               break;
            }
         }
      }
      setMaxReverse(maxReverseProp, setSel, getMaxCombined(maxCombinedProp, getSel, combined) - valueInAll, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[descendentMinWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [descendentMinWindowProp set:reverse forState:newState slideBy:1];
      [descendentMinWindowProp set:getMinCombined(minCombinedProp, getSel, combined) forState:newState at:0];
      return false;
   } copy];
   _reverseTransitionClosures[descendentMaxWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [descendentMaxWindowProp set:reverse forState:newState slideBy:1];
      [descendentMaxWindowProp set:getMaxCombined(maxCombinedProp, getSel, combined) forState:newState at:0];
      return false;
   } copy];
   
   _forwardPropertyImpactCount[minForward] = 2;
   _forwardPropertyImpactCount[maxForward] = 2;
   _forwardPropertyImpactCount[ancestorMinWindow] = 1;
   _forwardPropertyImpactCount[ancestorMaxWindow] = 1;
   _forwardPropertyImpact[minForward] = malloc(2 * sizeof(int));
   _forwardPropertyImpact[maxForward] = malloc(2 * sizeof(int));
   _forwardPropertyImpact[ancestorMinWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[ancestorMaxWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minForward][0] = minForward;
   _forwardPropertyImpact[minForward][1] = ancestorMinWindow;
   _forwardPropertyImpact[maxForward][0] = maxForward;
   _forwardPropertyImpact[maxForward][1] = ancestorMaxWindow;
   _forwardPropertyImpact[ancestorMinWindow][0] = ancestorMinWindow;
   _forwardPropertyImpact[ancestorMaxWindow][0] = ancestorMaxWindow;
   
   _reversePropertyImpactCount[minReverse] = 2;
   _reversePropertyImpactCount[maxReverse] = 2;
   _reversePropertyImpactCount[descendentMinWindow] = 1;
   _reversePropertyImpactCount[descendentMaxWindow] = 1;
   _reversePropertyImpact[minReverse] = malloc(2 * sizeof(int));
   _reversePropertyImpact[maxReverse] = malloc(2 * sizeof(int));
   _reversePropertyImpact[descendentMinWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[descendentMaxWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minReverse][0] = minReverse;
   _reversePropertyImpact[minReverse][1] = descendentMinWindow;
   _reversePropertyImpact[maxReverse][0] = maxReverse;
   _reversePropertyImpact[maxReverse][1] = descendentMaxWindow;
   _reversePropertyImpact[descendentMinWindow][0] = descendentMinWindow;
   _reversePropertyImpact[descendentMaxWindow][0] = descendentMaxWindow;
   
   _forwardRelaxationClosures[minForward] = [^(char* newState, char* state1,char* state2) {
      [minForwardProp set:min(getMinForward(minForwardProp,getSel,state1), getMinForward(minForwardProp,getSel,state2)) forState:newState];
   } copy];
   _forwardRelaxationClosures[maxForward] = [^(char* newState, char* state1,char* state2) {
      [maxForwardProp set:max(getMaxForward(maxForwardProp,getSel,state1), getMaxForward(maxForwardProp,getSel,state2)) forState:newState];
   } copy];
   _forwardRelaxationClosures[ancestorMinWindow] = [^(char* newState, char* state1,char* state2) {
      [ancestorMinWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[ancestorMaxWindow] = [^(char* newState, char* state1,char* state2) {
      [ancestorMaxWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[numAssigned] = [^(char* newState, char* state1,char* state2) {
      setNumAssignedForward(numAssignedProp, setSel, getNumAssignedForward(numAssignedProp, getSel, state1), newState);
   } copy];
   
   _reverseRelaxationClosures[minReverse] = [^(char* newState, char* state1,char* state2) {
      setMinReverse(minReverseProp, setSel, min(getMinReverse(minReverseProp,getSel,state1), getMinReverse(minReverseProp,getSel,state2)), newState);
   } copy];
   _reverseRelaxationClosures[maxReverse] = [^(char* newState, char* state1,char* state2) {
      setMaxReverse(maxReverseProp, setSel, max(getMaxReverse(maxReverseProp,getSel,state1), getMaxReverse(maxReverseProp,getSel,state2)), newState);
   } copy];
   _reverseRelaxationClosures[descendentMinWindow] = [^(char* newState, char* state1,char* state2) {
      [descendentMinWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _reverseRelaxationClosures[descendentMaxWindow] = [^(char* newState, char* state1,char* state2) {
      [descendentMaxWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   
   _updatePropertyClosures[minCombined] = [^(char* combined, char* forward, char* reverse) {
      int newMin = getMinForward(minForwardProp, getSel, forward);
      if (reverse != nil) {
         newMin = max(newMin, getMinReverse(minReverseProp, getSel, reverse));
         if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
            newMin = max(newMin, lb + [ancestorMinWindowProp get:forward at:length-1]);
         }
         if (getNumAssignedForward(numAssignedProp, getSel, forward) <= numVars - length) {
            newMin = max(newMin, [descendentMinWindowProp get:reverse at:length-1] - ub);
         }
      }
      if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
         newMin = max(newMin, lb + [ancestorMinWindowProp get:forward at:length-1]);
      }
      setMinCombined(minCombinedProp, setSel, newMin, combined);
   } copy];
   _updatePropertyClosures[maxCombined] = [^(char* combined, char* forward, char* reverse) {
      int newMax = getMaxForward(maxForwardProp, getSel, forward);
      if (reverse != nil) {
         newMax = min(newMax, getMaxReverse(maxReverseProp, getSel, reverse));
         if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
            newMax = min(newMax, ub + [ancestorMaxWindowProp get:forward at:length-1]);
         }
         if (getNumAssignedForward(numAssignedProp, getSel, forward) <= numVars - length) {
            newMax = min(newMax, [descendentMaxWindowProp get:reverse at:length-1] - lb);
         }
      }
      setMaxCombined(maxCombinedProp, setSel, newMax, combined);
   } copy];
   
   _stateExistsClosure = [^(char* forward, char* reverse, char* combined) {
      int minCombined = getMinCombined(minCombinedProp, getSel, combined);
      int maxCombined = getMaxCombined(maxCombinedProp, getSel, combined);
      return minCombined <= maxCombined &&
             minCombined >= 0 &&
             maxCombined <= getNumAssignedForward(numAssignedProp, getSel, forward);
   } copy];
}

-(void)setAsImprovedDualDirectionalSequence:(id<ORIntRange>)range numVars:(int)numVars length:(int)length lb:(int)lb ub:(int)ub values:(id<ORIntSet>)values {
   _dualDirectional = true;
   ORInt minDom = [range low];
   ORInt domSize = [range size];
   int minValue = [values min];
   int maxValue = [values max];
   int numValues = [values size];
   
   int numBytes = ceil((length-1)/8.0);
   int numInLastByte = (length-1) % 8;
   char bitsInLastByte = 0xff >> (8 - numInLastByte);
   
   int minForward = 0, maxForward = 1, ancestorMinCountWindow = 2, ancestorMaxCountWindow = 3, ancestorRowMinWindow = 4, ancestorRowMaxWindow = 5, numAssigned = 6;
   int minReverse = 0, maxReverse = 1, descendentMinCountWindow = 2, descendentMaxCountWindow = 3, descendentRowMinWindow = 4, descendentRowMaxWindow = 5;
   int minCombined = 0, maxCombined = 1;
   
   MDDPropertyDescriptor* minForwardProp = _forwardStateProperties[minForward];
   MDDPropertyDescriptor* maxForwardProp = _forwardStateProperties[maxForward];
   MDDPWindowShort* ancestorMinWindowProp = (MDDPWindowShort*)_forwardStateProperties[ancestorMinCountWindow];
   MDDPWindowShort* ancestorMaxWindowProp = (MDDPWindowShort*)_forwardStateProperties[ancestorMaxCountWindow];
   MDDPropertyDescriptor* ancestorRowMinWindowProp = _forwardStateProperties[ancestorRowMinWindow];
   MDDPropertyDescriptor* ancestorRowMaxWindowProp = _forwardStateProperties[ancestorRowMaxWindow];
   MDDPropertyDescriptor* numAssignedProp = _forwardStateProperties[numAssigned];
   
   MDDPropertyDescriptor* minReverseProp = _reverseStateProperties[minReverse];
   MDDPropertyDescriptor* maxReverseProp = _reverseStateProperties[maxReverse];
   MDDPWindowShort* descendentMinWindowProp = (MDDPWindowShort*)_reverseStateProperties[descendentMinCountWindow];
   MDDPWindowShort* descendentMaxWindowProp = (MDDPWindowShort*)_reverseStateProperties[descendentMaxCountWindow];
   MDDPropertyDescriptor* descendentRowMinWindowProp = _reverseStateProperties[descendentRowMinWindow];
   MDDPropertyDescriptor* descendentRowMaxWindowProp = _reverseStateProperties[descendentRowMaxWindow];
   
   MDDPropertyDescriptor* minCombinedProp = _combinedStateProperties[minCombined];
   MDDPropertyDescriptor* maxCombinedProp = _combinedStateProperties[maxCombined];
   
   SEL getSel = @selector(get:);
   SEL setSel = @selector(set:forState:);
   
   GetPropIMP getMinForward = (GetPropIMP)[minForwardProp methodForSelector:getSel];
   SetPropIMP setMinForward = (SetPropIMP)[minForwardProp methodForSelector:setSel];
   GetPropIMP getMaxForward = (GetPropIMP)[maxForwardProp methodForSelector:getSel];
   SetPropIMP setMaxForward = (SetPropIMP)[maxForwardProp methodForSelector:setSel];
   
   GetPropIMP getNumAssignedForward = (GetPropIMP)[numAssignedProp methodForSelector:getSel];
   SetPropIMP setNumAssignedForward = (SetPropIMP)[numAssignedProp methodForSelector:setSel];
   
   GetPropIMP getMinReverse = (GetPropIMP)[minReverseProp methodForSelector:getSel];
   SetPropIMP setMinReverse = (SetPropIMP)[minReverseProp methodForSelector:setSel];
   GetPropIMP getMaxReverse = (GetPropIMP)[maxReverseProp methodForSelector:getSel];
   SetPropIMP setMaxReverse = (SetPropIMP)[maxReverseProp methodForSelector:setSel];
   
   GetPropIMP getMinCombined = (GetPropIMP)[minCombinedProp methodForSelector:getSel];
   SetPropIMP setMinCombined = (SetPropIMP)[minCombinedProp methodForSelector:setSel];
   GetPropIMP getMaxCombined = (GetPropIMP)[maxCombinedProp methodForSelector:getSel];
   SetPropIMP setMaxCombined = (SetPropIMP)[maxCombinedProp methodForSelector:setSel];
   
   SEL getBitSel = @selector(getBitSequence:);
   GetBitsPropIMP getAncestorRowMins = (GetBitsPropIMP)[ancestorRowMinWindowProp methodForSelector:getBitSel];
   GetBitsPropIMP getAncestorRowMaxes = (GetBitsPropIMP)[ancestorRowMaxWindowProp methodForSelector:getBitSel];
   GetBitsPropIMP getDescendentRowMins = (GetBitsPropIMP)[descendentRowMinWindowProp methodForSelector:getBitSel];
   GetBitsPropIMP getDescendentRowMaxes = (GetBitsPropIMP)[descendentRowMaxWindowProp methodForSelector:getBitSel];
   
   bool* valueInSetLookup = calloc(domSize, sizeof(bool));
   valueInSetLookup -= minDom;
   [values enumerateWithBlock:^(ORInt value) {
      valueInSetLookup[value] = true;
   }];
   
   _arcExistsClosure = [^(char* parentForward, char* parentCombined, char* childReverse, char* childCombined, ORInt value) {
      int valueInSet = (value >= minValue && value <= maxValue && valueInSetLookup[value]);
      int numAssignedForward = getNumAssignedForward(numAssignedProp, getSel, parentForward);
      int minForSeq = 0;
      int maxForSeq = 0;
      char* ancestorRowMins = getAncestorRowMins(ancestorRowMinWindowProp, getBitSel, parentForward);
      char* ancestorRowMaxes = getAncestorRowMaxes(ancestorRowMaxWindowProp, getBitSel, parentForward);
      int i;
      for (i = 0; i < numBytes-4; i+=4) {
         minForSeq += __builtin_popcount(*(int*)&ancestorRowMins[i]);
         maxForSeq += __builtin_popcount(*(int*)&ancestorRowMaxes[i]);
      }
      for (; i < numBytes; i++) {
         minForSeq += _numBitsInByteLookup[(unsigned char)ancestorRowMins[i]];
         maxForSeq += _numBitsInByteLookup[(unsigned char)ancestorRowMaxes[i]];
      }
      if (minForSeq + valueInSet > ub || (numAssigned+1 >= length && maxForSeq + valueInSet < lb)) {
         return false;
      }
      if (childReverse != nil) {
         int minForSeq = 0;
         int maxForSeq = 0;
         char* descendentRowMins = getDescendentRowMins(descendentRowMinWindowProp, getBitSel, childReverse);
         char* descendentRowMaxes = getDescendentRowMaxes(descendentRowMaxWindowProp, getBitSel, childReverse);
         int i;
         for (i = 0; i < numBytes-4; i+=4) {
            minForSeq += __builtin_popcount(*(int*)&descendentRowMins[i]);
            maxForSeq += __builtin_popcount(*(int*)&descendentRowMaxes[i]);
         }
         for (; i < numBytes; i++) {
            minForSeq += _numBitsInByteLookup[(unsigned char)descendentRowMins[i]];
            maxForSeq += _numBitsInByteLookup[(unsigned char)descendentRowMaxes[i]];
         }
         if (minForSeq + valueInSet > ub || (numVars - numAssignedForward > length && maxForSeq + valueInSet < lb)) {
            return false;
         }
      }
      return true;
   } copy];
   
   _forwardTransitionClosures[minForward] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      }
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               valueInSome = true;
            } else {
               valueInAll = false;
            }
            if (valueInSome && !valueInAll) {
               break;
            }
         }
      }
      if (combined == nil) {
         setMinForward(minForwardProp, setSel, getMinForward(minForwardProp, getSel, forward) + valueInAll, newState);
      } else {
         setMinForward(minForwardProp, setSel, getMinCombined(minCombinedProp, getSel, combined) + valueInAll, newState);
      }
      return valueInSome && !valueInAll;
   } copy];
   _forwardTransitionClosures[maxForward] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      }
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               valueInSome = true;
            } else {
               valueInAll = false;
            }
            if (valueInSome && !valueInAll) {
               break;
            }
         }
      }
      if (combined == nil) {
         setMaxForward(maxForwardProp, setSel, getMaxForward(maxForwardProp, getSel, forward) + valueInSome, newState);
      } else {
         setMaxForward(maxForwardProp, setSel, getMaxCombined(maxCombinedProp, getSel, combined) + valueInSome, newState);
      }
      return valueInSome && !valueInAll;
   } copy];
   _forwardTransitionClosures[ancestorMinCountWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [ancestorMinWindowProp set:forward forState:newState slideBy:1];
      if (combined == nil) {
         [ancestorMinWindowProp set:getMinForward(minForwardProp, getSel, forward) forState:newState at:0];
      } else {
         [ancestorMinWindowProp set:getMinCombined(minCombinedProp, getSel, combined) forState:newState at:0];
      }
      return false;
   } copy];
   _forwardTransitionClosures[ancestorMaxCountWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [ancestorMaxWindowProp set:forward forState:newState slideBy:1];
      if (combined == nil) {
         [ancestorMaxWindowProp set:getMaxForward(maxForwardProp, getSel, forward) forState:newState at:0];
      } else {
         [ancestorMaxWindowProp set:getMaxCombined(maxCombinedProp, getSel, combined) forState:newState at:0];
      }
      return false;
   } copy];
   _forwardTransitionClosures[ancestorRowMinWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      char* newMinWindow = getAncestorRowMins(ancestorRowMinWindowProp, getBitSel, newState);
      char* oldMinWindow = getAncestorRowMins(ancestorRowMinWindowProp, getBitSel, forward);
      bool carry = true;
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (!(i >= minValue && i <= maxValue && valueInSetLookup[i])) {
               carry = false;
               break;
            }
         }
      }
      for (int i = 0; i < numBytes; i++) {
         newMinWindow[i] = carry | (oldMinWindow[i] << 1);
         carry = (oldMinWindow[i] & 0x80) ? 1 : 0;
      }
      newMinWindow[numBytes-1] &= bitsInLastByte;
      return false;
   } copy];
   _forwardTransitionClosures[ancestorRowMaxWindow] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      char* newMaxWindow = getAncestorRowMaxes(ancestorRowMaxWindowProp, getBitSel, newState);
      char* oldMaxWindow = getAncestorRowMaxes(ancestorRowMaxWindowProp, getBitSel, forward);
      bool carry = false;
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               carry = true;
               break;
            }
         }
      }
      for (int i = 0; i < numBytes; i++) {
         newMaxWindow[i] = carry | (oldMaxWindow[i] << 1);
         carry = (oldMaxWindow[i] & 0x80) ? 1 : 0;
      }
      newMaxWindow[numBytes-1] &= bitsInLastByte;
      return false;
   } copy];
   _forwardTransitionClosures[numAssigned] = [^(char* newState, char* forward, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      setNumAssignedForward(numAssignedProp, setSel, getNumAssignedForward(numAssignedProp, getSel, forward) + 1, newState);
   } copy];
   
   _reverseTransitionClosures[minReverse] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInSome = false;
      for (int i = minDom; i <= maxDom; i++) {
         if (valueSet[i] && i >= minValue && i <= maxValue && valueInSetLookup[i]) {
            valueInSome = true;
            break;
         }
      }
      setMinReverse(minReverseProp, setSel, getMinCombined(minCombinedProp, getSel, combined) - valueInSome, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[maxReverse] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      bool valueInAll = true;
      if (numArcs > numValues) {
         valueInAll = false;
      } else {
         for (int i = minDom; i <= maxDom; i++) {
            if (valueSet[i] && !(i >= minValue && i <= maxValue && valueInSetLookup[i])) {
               valueInAll = false;
               break;
            }
         }
      }
      setMaxReverse(maxReverseProp, setSel, getMaxCombined(maxCombinedProp, getSel, combined) - valueInAll, newState);
      return numArcs > 1;
   } copy];
   _reverseTransitionClosures[descendentMinCountWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [descendentMinWindowProp set:reverse forState:newState slideBy:1];
      [descendentMinWindowProp set:getMinCombined(minCombinedProp, getSel, combined) forState:newState at:0];
      return false;
   } copy];
   _reverseTransitionClosures[descendentMaxCountWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      [descendentMaxWindowProp set:reverse forState:newState slideBy:1];
      [descendentMaxWindowProp set:getMaxCombined(maxCombinedProp, getSel, combined) forState:newState at:0];
      return false;
   } copy];
   _reverseTransitionClosures[descendentRowMinWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      char* newMinWindow = getDescendentRowMins(descendentRowMinWindowProp, getBitSel, newState);
      char* oldMinWindow = getDescendentRowMins(descendentRowMinWindowProp, getBitSel, reverse);
      bool carry = true;
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (!(i >= minValue && i <= maxValue && valueInSetLookup[i])) {
               carry = false;
               break;
            }
         }
      }
      for (int i = 0; i < numBytes; i++) {
         newMinWindow[i] = carry | (oldMinWindow[i] << 1);
         carry = (oldMinWindow[i] & 0x80) ? 1 : 0;
      }
      newMinWindow[numBytes-1] &= bitsInLastByte;
      return false;
   } copy];
   _reverseTransitionClosures[descendentRowMaxWindow] = [^(char* newState, char* reverse, char* combined, bool* valueSet, int numArcs, int minDom, int maxDom) {
      char* newMaxWindow = getDescendentRowMaxes(descendentRowMaxWindowProp, getBitSel, newState);
      char* oldMaxWindow = getDescendentRowMaxes(descendentRowMaxWindowProp, getBitSel, reverse);
      bool carry = false;
      for (int i = minDom; numArcs; i++) {
         if (valueSet[i]) {
            numArcs--;
            if (i >= minValue && i <= maxValue && valueInSetLookup[i]) {
               carry = true;
               break;
            }
         }
      }
      for (int i = 0; i < numBytes; i++) {
         newMaxWindow[i] = carry | (oldMaxWindow[i] << 1);
         carry = (oldMaxWindow[i] & 0x80) ? 1 : 0;
      }
      newMaxWindow[numBytes-1] &= bitsInLastByte;
      return false;
   } copy];
   
   _forwardPropertyImpactCount[minForward] = 2;
   _forwardPropertyImpactCount[maxForward] = 2;
   _forwardPropertyImpactCount[ancestorMinCountWindow] = 1;
   _forwardPropertyImpactCount[ancestorMaxCountWindow] = 1;
   _forwardPropertyImpactCount[ancestorRowMinWindow] = 1;
   _forwardPropertyImpactCount[ancestorRowMaxWindow] = 1;
   _forwardPropertyImpact[minForward] = malloc(2 * sizeof(int));
   _forwardPropertyImpact[maxForward] = malloc(2 * sizeof(int));
   _forwardPropertyImpact[ancestorMinCountWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[ancestorMaxCountWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[ancestorRowMinWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[ancestorRowMaxWindow] = malloc(1 * sizeof(int));
   _forwardPropertyImpact[minForward][0] = minForward;
   _forwardPropertyImpact[minForward][1] = ancestorMinCountWindow;
   _forwardPropertyImpact[maxForward][0] = maxForward;
   _forwardPropertyImpact[maxForward][1] = ancestorMaxCountWindow;
   _forwardPropertyImpact[ancestorMinCountWindow][0] = ancestorMinCountWindow;
   _forwardPropertyImpact[ancestorMaxCountWindow][0] = ancestorMaxCountWindow;
   _forwardPropertyImpact[ancestorRowMinWindow][0] = ancestorRowMinWindow;
   _forwardPropertyImpact[ancestorRowMaxWindow][0] = ancestorRowMaxWindow;
   
   _reversePropertyImpactCount[minReverse] = 2;
   _reversePropertyImpactCount[maxReverse] = 2;
   _reversePropertyImpactCount[descendentMinCountWindow] = 1;
   _reversePropertyImpactCount[descendentMaxCountWindow] = 1;
   _reversePropertyImpactCount[descendentRowMinWindow] = 1;
   _reversePropertyImpactCount[descendentRowMaxWindow] = 1;
   _reversePropertyImpact[minReverse] = malloc(2 * sizeof(int));
   _reversePropertyImpact[maxReverse] = malloc(2 * sizeof(int));
   _reversePropertyImpact[descendentMinCountWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[descendentMaxCountWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[descendentRowMinWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[descendentRowMaxWindow] = malloc(1 * sizeof(int));
   _reversePropertyImpact[minReverse][0] = minReverse;
   _reversePropertyImpact[minReverse][1] = descendentMinCountWindow;
   _reversePropertyImpact[maxReverse][0] = maxReverse;
   _reversePropertyImpact[maxReverse][1] = descendentMaxCountWindow;
   _reversePropertyImpact[descendentMinCountWindow][0] = descendentMinCountWindow;
   _reversePropertyImpact[descendentMaxCountWindow][0] = descendentMaxCountWindow;
   _reversePropertyImpact[descendentRowMinWindow][0] = descendentRowMinWindow;
   _reversePropertyImpact[descendentRowMaxWindow][0] = descendentRowMaxWindow;
   
   _forwardRelaxationClosures[minForward] = [^(char* newState, char* state1,char* state2) {
      [minForwardProp set:min(getMinForward(minForwardProp,getSel,state1), getMinForward(minForwardProp,getSel,state2)) forState:newState];
   } copy];
   _forwardRelaxationClosures[maxForward] = [^(char* newState, char* state1,char* state2) {
      [maxForwardProp set:max(getMaxForward(maxForwardProp,getSel,state1), getMaxForward(maxForwardProp,getSel,state2)) forState:newState];
   } copy];
   _forwardRelaxationClosures[ancestorMinCountWindow] = [^(char* newState, char* state1,char* state2) {
      [ancestorMinWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[ancestorMaxCountWindow] = [^(char* newState, char* state1,char* state2) {
      [ancestorMaxWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   _forwardRelaxationClosures[ancestorRowMinWindow] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[ancestorRowMinWindowProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] & state2[i];
      }
   } copy];
   _forwardRelaxationClosures[ancestorRowMaxWindow] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[ancestorRowMaxWindowProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   _forwardRelaxationClosures[numAssigned] = [^(char* newState, char* state1,char* state2) {
      setNumAssignedForward(numAssignedProp, setSel, getNumAssignedForward(numAssignedProp, getSel, state1), newState);
   } copy];
   
   _reverseRelaxationClosures[minReverse] = [^(char* newState, char* state1,char* state2) {
      setMinReverse(minReverseProp, setSel, min(getMinReverse(minReverseProp,getSel,state1), getMinReverse(minReverseProp,getSel,state2)), newState);
   } copy];
   _reverseRelaxationClosures[maxReverse] = [^(char* newState, char* state1,char* state2) {
      setMaxReverse(maxReverseProp, setSel, max(getMaxReverse(maxReverseProp,getSel,state1), getMaxReverse(maxReverseProp,getSel,state2)), newState);
   } copy];
   _reverseRelaxationClosures[descendentMinCountWindow] = [^(char* newState, char* state1,char* state2) {
      [descendentMinWindowProp set:newState toMinOf:state1 and:state2];
   } copy];
   _reverseRelaxationClosures[descendentMaxCountWindow] = [^(char* newState, char* state1,char* state2) {
      [descendentMaxWindowProp set:newState toMaxOf:state1 and:state2];
   } copy];
   _reverseRelaxationClosures[descendentRowMinWindow] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[descendentRowMinWindowProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] & state2[i];
      }
   } copy];
   _reverseRelaxationClosures[descendentRowMaxWindow] = [^(char* newState, char* state1,char* state2) {
      int firstByte = (int)[descendentRowMaxWindowProp byteOffset];
      int lastByte = firstByte + numBytes;
      for (int i = firstByte; i < lastByte; i++) {
         newState[i] = state1[i] | state2[i];
      }
   } copy];
   
   _updatePropertyClosures[minCombined] = [^(char* combined, char* forward, char* reverse) {
      int newMin = getMinForward(minForwardProp, getSel, forward);
      if (reverse != nil) {
         newMin = max(newMin, getMinReverse(minReverseProp, getSel, reverse));
         if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
            newMin = max(newMin, lb + [ancestorMinWindowProp get:forward at:length-1]);
         }
         if (getNumAssignedForward(numAssignedProp, getSel, forward) <= numVars - length) {
            newMin = max(newMin, [descendentMinWindowProp get:reverse at:length-1] - ub);
         }
      }
      if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
         newMin = max(newMin, lb + [ancestorMinWindowProp get:forward at:length-1]);
      }
      setMinCombined(minCombinedProp, setSel, newMin, combined);
   } copy];
   _updatePropertyClosures[maxCombined] = [^(char* combined, char* forward, char* reverse) {
      int newMax = getMaxForward(maxForwardProp, getSel, forward);
      if (reverse != nil) {
         newMax = min(newMax, getMaxReverse(maxReverseProp, getSel, reverse));
         if (getNumAssignedForward(numAssignedProp, getSel, forward) >= length) {
            newMax = min(newMax, ub + [ancestorMaxWindowProp get:forward at:length-1]);
         }
         if (getNumAssignedForward(numAssignedProp, getSel, forward) <= numVars - length) {
            newMax = min(newMax, [descendentMaxWindowProp get:reverse at:length-1] - lb);
         }
      }
      setMaxCombined(maxCombinedProp, setSel, newMax, combined);
   } copy];
   
   _stateExistsClosure = [^(char* forward, char* reverse, char* combined) {
      int minCombined = getMinCombined(minCombinedProp, getSel, combined);
      int maxCombined = getMaxCombined(maxCombinedProp, getSel, combined);
      return minCombined <= maxCombined &&
             minCombined >= 0 &&
             maxCombined <= getNumAssignedForward(numAssignedProp, getSel, forward);
   } copy];
}

-(void)dealloc
{
   for (int i = 0; i < _numForwardProperties; i++) {
      [_forwardStateProperties[i] release];
      if (_forwardPropertyImpactCount[i]) {
         free(_forwardPropertyImpact[i]);
      }
   }
   free(_forwardStateProperties);
   free(_forwardPropertyImpact);
   free(_forwardPropertyImpactCount);
   for (int i = 0; i < _numReverseProperties; i++) {
      [_reverseStateProperties[i] release];
      if (_reversePropertyImpactCount[i]) {
         free(_reversePropertyImpact[i]);
      }
   }
   free(_reverseStateProperties);
   free(_reversePropertyImpact);
   free(_reversePropertyImpactCount);
   for (int i = 0; i < _numCombinedProperties; i++) {
      [_combinedStateProperties[i] release];
   }
   free(_combinedStateProperties);
   free(_forwardTransitionClosures);
   free(_reverseTransitionClosures);
   free(_forwardRelaxationClosures);
   free(_reverseRelaxationClosures);
   free(_updatePropertyClosures);
   
   free(_numBitsInByteLookup);
   
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@)",[self class],self,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMDDSpecs:self];
}
-(id<ORIntVarArray>) vars
{
   return _x;
}

-(DDArcExistsClosure)arcExistsClosure { return _arcExistsClosure; }
-(DDStateExistsClosure)stateExistsClosure { return _stateExistsClosure; }
-(DDArcSetTransitionClosure*)forwardTransitionClosures { return _forwardTransitionClosures; }
-(DDArcSetTransitionClosure*)reverseTransitionClosures { return _reverseTransitionClosures; }
-(DDMergeClosure*)forwardRelaxationClosures { return _forwardRelaxationClosures; }
-(DDMergeClosure*)reverseRelaxationClosures { return _reverseRelaxationClosures; }
-(DDUpdatePropertyClosure*)updatePropertyClosures { return _updatePropertyClosures; }
-(int)numForwardProperties { return _numForwardProperties; }
-(int)numReverseProperties { return _numReverseProperties; }
-(int)numCombinedProperties { return _numCombinedProperties; }
-(id*)forwardStateProperties { return _forwardStateProperties; }
-(id*)reverseStateProperties { return _reverseStateProperties; }
-(id*)combinedStateProperties { return _combinedStateProperties; }
-(int**)forwardPropertyImpact { return _forwardPropertyImpact; }
-(int*)forwardPropertyImpactCount { return _forwardPropertyImpactCount; }
-(int**)reversePropertyImpact { return _reversePropertyImpact; }
-(int*)reversePropertyImpactCount { return _reversePropertyImpactCount; }
-(id<ORIntVar>)fixpointVar { return _fixpointVar; }
-(DDFixpointBoundClosure)fixpointMin { return _fixpointMin; }
-(DDFixpointBoundClosure)fixpointMax { return _fixpointMax; }
-(DDNodeSplitValueClosure)nodeSplitValueClosure { return _nodeSplitValueClosure; }
-(DDCandidateSplitValueClosure)candidateSplitValueClosure { return _candidateSplitValueClosure; }
-(DDStateEquivalenceClassClosure)approximateEquivalenceClosure { return _approximateEquivalenceClosure; }

-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
@end

@interface ORAlphaVisit : ORVisitor {
   id<ORVarArray> _map;
   id<ORConstraint> _result;
}
-(ORAlphaVisit*)initAlpha:(id<ORVarArray>)va;
-(id<ORConstraint>)result;
+(id<ORConstraint>)alphaRename:(id<ORConstraint>)c  with:(id<ORVarArray>)m;
@end

@implementation ORAlphaVisit
-(ORAlphaVisit*)initAlpha:(id<ORVarArray>)va
{
   self = [super init];
   _map = va;
   _result = nil;
   return self;
}
-(void)dealloc
{
   [super dealloc];
}
-(id<ORConstraint>)result
{
   return _result;
}
+(id<ORConstraint>)alphaRename:(id<ORConstraint>)c with:(id<ORVarArray>)m
{
   ORAlphaVisit* v = [[ORAlphaVisit alloc] initAlpha:m];
   [c visit:v];
   id<ORConstraint> result = v.result;
   [v release];
   return result;
}
-(void) visitEqualc: (id<OREqualc>)c
{
   
}
-(void) visitNEqualc: (id<ORNEqualc>)c
{
   
}
-(void) visitLEqualc: (id<ORLEqualc>)c
{
   
}
-(void) visitGEqualc: (id<ORGEqualc>)c
{
   
}
-(void) visitEqual: (id<OREqual>)c
{
   id<ORVar> clp = _map[getId(c.left)];
   id<ORVar> crp = _map[getId(c.right)];
   id<ORTracker> t = [(id)crp tracker];
   _result = [ORFactory equal:t var:clp to:crp plus:c.cst];
}
@end

@implementation ORConstraintI
-(ORConstraintI*) initORConstraintI
{
   self = [super init];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p>",[self class],self];
   return buf;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitConstraint:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] init] autorelease];
}
-(void) close
{
   
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   return self;
}
@end

@implementation ORGroupI {
   NSMutableArray* _content;
   id<ORTracker>     _model;
   enum ORGroupType     _gt;
   id<ORIntVar>      _guard;
}
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt
{
   self = [super init];
   _model = model;
   _content = [[NSMutableArray alloc] initWithCapacity:8];
   _name = -1;
   _gt = gt;
   _guard = nil;
   return self;
}
-(ORGroupI*)initORGroupI:(id<ORTracker>)model type:(enum ORGroupType)gt guard:(id<ORIntVar>)g
{
   self = [super init];
   _model = model;
   _content = [[NSMutableArray alloc] initWithCapacity:8];
   _name = -1;
   _gt = gt;
   _guard = g;
   return self;
}
-(void)dealloc
{
   [_content release];
   [super dealloc];
}
-(id<ORConstraint>)add:(id<ORConstraint>)c
{
   if ([[c class] conformsToProtocol:@protocol(ORRelation)])
      c = [ORFactory algebraicConstraint:_model expr: (id<ORRelation>)c];
   [_content addObject:c];
   [_model trackConstraintInGroup:c];
   return c;
}
-(void)clear
{
   [_content removeAllObjects];
}

-(id<ORIntVar>)guard
{
   return _guard;
}
-(NSSet*)allVars
{
   NSMutableSet* os = [[[NSMutableSet alloc] initWithCapacity:2] autorelease];
   if (_guard) [os addObject:_guard];
   @autoreleasepool {
      for(id<ORConstraint> c in _content) {
         NSSet* cs = [c allVars];
         [os unionSet:cs];
      }
   }
   return os;
}

-(id<ORConstraint>)alphaVars:(id<ORVarArray>) xa
{
   id<ORGroup> gp = [ORFactory group:_model type:_gt guard:_guard];
   for(id<ORConstraint> c in _content) {
      id<ORConstraint> cp = [ORAlphaVisit alphaRename:c with: xa];
      [gp add:cp];
   }
   return gp;
}

-(void) close
{
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   const char* gt;
   switch(_gt) {
      case DefaultGroup: gt = "def";break;
      case BergeGroup: gt = "berge";break;
      case GuardedGroup: gt = "guarded";break;
      case CDGroup: gt = "cdisj";break;
   }
   [buf appendFormat:@"<%@ (%s): %p> -> ",[self class],gt,self];
   [buf appendString:@"{\n"];
   [_content enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
      [buf appendFormat:@"\t\t%@\n",[obj description]];
   }];
   [buf appendString:@"\t}"];
   if (_gt == GuardedGroup)
      [buf appendFormat:@" guard: %@",_guard];
   return buf;
}
-(void)enumerateObjectWithBlock:(void(^)(id<ORConstraint>))block
{
   for(id obj in _content)
      block(obj);
}
-(ORInt) size
{
    return (ORInt)[_content count];
}
-(id<ORConstraint>) at: (ORInt) idx
{
    return [_content objectAtIndex: idx];
}

-(void) visit: (ORVisitor*) visitor
{
   [visitor visitGroup:self];
}
-(enum ORGroupType)type
{
   return _gt;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_content];
   [aCoder encodeObject:_model];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_gt];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _content = [aDecoder decodeObject];
   _model   = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_gt];
   return self;
}
@end

@implementation ORCDisjGroupI {
   NSArray* _varMap;
}
-(ORCDisjGroupI*)initORCDGroupI:(id<ORTracker>)model
{
   self = [super initORGroupI: model type: CDGroup];
   _varMap = nil;
   return self;
}
-(ORCDisjGroupI*)initORCDGroupI:(id<ORTracker>)model witMap:(NSArray*)vMap
{
   self = [super initORGroupI: model type: CDGroup];
   _varMap = [vMap retain];
   return self;
}
-(void) dealloc
{
   [_varMap release];
   [super dealloc];
}
-(NSArray*)varMap
{
   return _varMap;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitCDGroup:self];
}
@end


@implementation ORFail
-(ORFail*)init
{
   self = [super init];
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> fail",[self class],self];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitFail:self];
}
@end

@implementation ORRestrict {
   id<ORIntVar> _x;
   id<ORIntSet> _r;
}
-(ORRestrict*)initRestrict:(id<ORIntVar>)x to:(id<ORIntSet>)d
{
   self = [super initORConstraintI];
   _x = x;
   _r = d;
   return self;
}
-(id<ORIntVar>)var
{
   return _x;
}
-(id<ORIntSet>)restriction
{
   return _r;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> restrict(%@) to %@",[self class],self,_x,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRestrict:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_r];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _r = [aDecoder decodeObject];
   return self;
}
@end

@implementation OREqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(OREqualc*)initOREqualc:(id<ORIntVar>)x eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(void)dealloc
{
   //NSLog(@"OREqualc::dealloc: %p",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORRealEqualc {
   id<ORRealVar> _x;
   ORDouble        _c;
}
-(ORRealEqualc*)init:(id<ORRealVar>)x eqi:(ORDouble)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %f)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealEqualc:self];
}
-(id<ORRealVar>) left
{
   return _x;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORDouble) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORDouble) at:&_c];
   return self;
}
@end

@implementation ORNEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORNEqualc*)initORNEqualc:(id<ORIntVar>)x neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ != %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitNEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORLEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORLEqualc*)initORLEqualc:(id<ORIntVar>)x leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <= %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitLEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORGEqualc {
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORGEqualc*)initORGEqualc:(id<ORIntVar>)x geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ >= %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitGEqualc:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end


@implementation OREqual {
   id<ORVar> _x;
   id<ORVar> _y;
   ORInt     _c;
}
-(id)initOREqual:(id<ORVar>)x eq:(id<ORVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ + %d)",[self class],self,_x,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitEqual:self];
}
-(id<ORVar>) left
{
   return _x;
}
-(id<ORVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORAffine {   // y == a * x + b
   ORInt _a;
   ORInt _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORAffine*)initORAffine: (id<ORIntVar>) y eq:(ORInt)a times:(id<ORIntVar>) x plus: (ORInt) b
{
   self = [super initORConstraintI];
   _a = a;
   _b = b;
   _x = x;
   _y = y;
   assert(a != 0);
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d * %@ + %d)",[self class],self,_y,_a,_x,_b];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAffine:self];
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _x;
}
-(ORInt)coef
{
   return _a;
}
-(ORInt)cst
{
   return _b;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORNEqual {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = 0;
   return self;
}
-(ORNEqual*)initORNEqual:(id<ORIntVar>)x neq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _c = c;
   return self;   
}
-(void)encodeWithCoder:(NSCoder *)aCoder
{
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
-(id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super init];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ != %@ + %d)",[self class],self,_x,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitNEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORSoftNEqual {
    id<ORVar> _slack;
}
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y slack: (id<ORVar>)slack {
   self = [super initORNEqual: x neq: y];
   if(self) _slack = slack;
   return self;
}
-(id) initORSoftNEqual: (id<ORIntVar>) x neq: (id<ORIntVar>) y plus: (ORInt) c slack: (id<ORVar>)slack {
   self = [super initORNEqual: x neq: y plus: c];
   if(self) _slack = slack;
   return self;
}
-(id<ORVar>) slack
{
   return _slack;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSoftNEqual:self];
}
@end

@implementation ORLEqual {  // a * x ≤ b * y + c
   ORInt     _a,_b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   ORInt        _c;
}
-(ORLEqual*)initORLEqual:(id<ORIntVar>)x leq:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _a = _b = 1;
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(ORLEqual*)initORLEqual:(ORInt)a times:(id<ORIntVar>)x leq:(ORInt)b times:(id<ORIntVar>)y plus:(ORInt)c
{
   self = [super initORConstraintI];
   _a = a;
   _b = b;
   _x = x;
   _y = y;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%d * %@ <= %d * %@ + %d)",[self class],self,_a,_x,_b,_y,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitLEqual:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(ORInt) cst
{
   return _c;
}
-(ORInt) coefLeft
{
   return _a;
}
-(ORInt) coefRight
{
   return _b;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_a];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_b];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_a];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_b];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORPlus {
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORPlus*)initORPlus:(id<ORIntVar>)x eq:(id<ORIntVar>)y plus:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ + %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitPlus:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORMult { // x = y * z
   id<ORVar> _x;
   id<ORVar> _y;
   id<ORVar> _z;
}
-(ORMult*)initORMult:(id<ORVar>)x eq:(id<ORVar>)y times:(id<ORVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ * %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMult:self];
}
-(id<ORVar>) res
{
   return _x;
}
-(id<ORVar>) left
{
   return _y;
}
-(id<ORVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORSquare { // z == x^2
   id<ORVar> _z;
   id<ORVar> _x;
}
-(id)init:(id<ORVar>)z square:(id<ORVar>)x
{
   self = [super initORConstraintI];
   _x = x;
   _z = z;
   return self;
}
-(id<ORVar>)res
{
   return _z;
}
-(id<ORVar>)op
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ ^ 2)",[self class],self,_z,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSquare:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORRealSquare
-(void)visit:(ORVisitor*)v
{
   [v visitRealSquare:self];
}
@end

@implementation ORMod { // z = x MOD y
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMod*)initORMod:(id<ORIntVar>)x mod:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ MOD %@)",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMod:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
   [aCoder encodeObject:_z];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   _z = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORModc { // z = x MOD y  (y==c)
   id<ORIntVar> _x;
   ORInt        _y;
   id<ORIntVar> _z;
}
-(ORModc*)initORModc:(id<ORIntVar>)x mod:(ORInt)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ MOD %d)",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitModc:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(ORInt) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_z, nil] autorelease];
}
@end

@implementation ORMin { // z = min(x,y)
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMin*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == MIN(%@,%@))",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMin:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORMax { // z = max(x,y)
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORMax*)init:(id<ORIntVar>)x and:(id<ORIntVar>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == MAX(%@,%@))",[self class],self,_z,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMax:self];
}
-(id<ORIntVar>) res
{
   return _z;
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORAbs { // x = |y|
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORAbs*)initORAbs:(id<ORIntVar>)x eqAbs:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == abs(%@))",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAbs:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end


@implementation OROr { // x = y || z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(OROr*)initOROr:(id<ORIntVar>)x eq:(id<ORIntVar>)y or:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ || %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitOr:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORAnd { // x = y && z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORAnd*)initORAnd:(id<ORIntVar>)x eq:(id<ORIntVar>)y and:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ && %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAnd:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORImply { // x = y => z
   id<ORIntVar> _x;
   id<ORIntVar> _y;
   id<ORIntVar> _z;
}
-(ORImply*)initORImply:(id<ORIntVar>)x eq:(id<ORIntVar>)y imply:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == (%@ => %@))",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitImply:self];
}
-(id<ORIntVar>) res
{
   return _x;
}
-(id<ORIntVar>) left
{
   return _y;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end


@implementation ORBinImply { // x => y
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORBinImply*)init:(id<ORIntVar>)x imply:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> %@ => %@ >",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBinImply:self];
}
-(id<ORIntVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end


@implementation ORSetContains {  // set.contains(value) == z
   id<ORIntSet> _set;
   id<ORIntVar> _value;
   id<ORIntVar> _z;
}
-(ORSetContains*)initORSetContains:(id<ORIntSet>)set value:(id<ORIntVar>)value equal:(id<ORIntVar>)z {
   self = [super initORConstraintI];
   _set = set;
   _value = value;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@.contains(%@) == %@)",[self class],self,_set,_value,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSetContains:self];
}
-(id<ORIntSet>) set
{
   return _set;
}
-(id<ORIntVar>) value
{
   return _value;
}
-(id<ORIntVar>) right
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_value,_z, nil] autorelease];
}
@end


@implementation ORElementCst {  // y[idx] == z
   id<ORIntVar>   _idx;
   id<ORIntArray> _y;
   id<ORIntVar>   _z;
}
-(ORElementCst*)initORElement:(id<ORIntVar>)idx array:(id<ORIntArray>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementCst:self];
}
-(id<ORIntArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORIntVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_idx,_z, nil] autorelease];
}
@end

@implementation ORElementVar {  // y[idx] == z
   id<ORIntVar>     _idx;
   id<ORIntVarArray>  _y;
   id<ORIntVar>       _z;
}
-(ORElementVar*)initORElement:(id<ORIntVar>)idx array:(id<ORIntVarArray>)y equal:(id<ORIntVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementVar:self];
}
-(id<ORIntVarArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORIntVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
@end

@implementation ORElementBitVar {  // y[idx] == z
   id<ORBitVar>     _idx;
   id<ORIdArray>  _y;
   id<ORBitVar>       _z;
}
-(ORElementBitVar*)initORElement:(id<ORBitVar>)idx array:(id<ORIdArray>)y equal:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementBitVar:self];
}
-(id<ORIdArray>) array
{
   return _y;
}
-(id<ORBitVar>) idx
{
   return _idx;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_y count]] autorelease];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_idx];
   [ms addObject:_z];
   return ms;
}
@end

@implementation ORElementMatrixVar {
   id<ORIntVarMatrix> _m;
   id<ORIntVar> _v0;
   id<ORIntVar> _v1;
   id<ORIntVar> _y;
}
-(id)initORElement:(id<ORIntVarMatrix>)m elt:(id<ORIntVar>)v0 elt:(id<ORIntVar>)v1 equal:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _m = m;
   _v0 = v0;
   _v1 = v1;
   _y  = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@,%@] == %@)",[self class],self,_m,_v0,_v1,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitElementMatrixVar:self];
}
-(id<ORIntVarMatrix>)matrix
{
   return _m;
}
-(id<ORIntVar>)index0
{
   return _v0;
}
-(id<ORIntVar>)index1
{
   return _v1;
}
-(id<ORIntVar>) res
{
   return _y;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:2 + [_m count]] autorelease];
   [[_m range:0] enumerateWithBlock:^(ORInt i) {
      [[_m range:1] enumerateWithBlock:^(ORInt j) {
         [ms addObject:[_m at:i :j]];
      }];
   }];
   [ms addObject:_v0];
   [ms addObject:_v1];
   [ms addObject:_y];
   return ms;
}
@end


@implementation ORRealElementCst {  // y[idx] == z
   id<ORIntVar>   _idx;
   id<ORDoubleArray> _y;
   id<ORRealVar>   _z;
}
-(id)initORElement:(id<ORIntVar>)idx array:(id<ORDoubleArray>)y equal:(id<ORRealVar>)z
{
   self = [super initORConstraintI];
   _idx = idx;
   _y = y;
   _z = z;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%@] == %@)",[self class],self,_y,_idx,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealElementCst:self];
}
-(id<ORDoubleArray>) array
{
   return _y;
}
-(id<ORIntVar>) idx
{
   return _idx;
}
-(id<ORRealVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_idx,_z, nil] autorelease];
}
@end


@implementation ORImplyEqualc {
    id<ORIntVar> _b;
    id<ORIntVar> _x;
    ORInt        _c;
}
-(ORImplyEqualc*)initImply:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c
{
    self = [super initORConstraintI];
    _b = b;
    _x = x;
    _c = c;
    return self;
}
-(NSString*) description
{
    NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
    [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %d)",[self class],self,_b,_x,_c];
    return buf;
}
-(void)visit:(ORVisitor*)v
{
    [v visitImplyEqualc:self];
}
-(id<ORIntVar>) b
{
    return _b;
}
-(id<ORIntVar>) x
{
    return _x;
}
-(ORInt) cst
{
    return _c;
}
-(NSSet*)allVars
{
    return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
    [super encodeWithCoder:aCoder];
    [aCoder encodeObject:_b];
    [aCoder encodeObject:_x];
    [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    _b = [aDecoder decodeObject];
    _x = [aDecoder decodeObject];
    [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
    return self;
}
@end


@implementation ORReifyEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyNEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyNEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ != %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyNEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x eq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ == %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORReifyNEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyNEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x neq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ != %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyNEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORReifyLEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyLEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ <= %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyLEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyLEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyLEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x leq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ <= %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyLEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

@implementation ORReifyGEqualc {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   ORInt        _c;
}
-(ORReifyGEqualc*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ >= %d)",[self class],self,_b,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyGEqualc:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifyGEqual {
   id<ORIntVar> _b;
   id<ORIntVar> _x;
   id<ORIntVar> _y;
}
-(ORReifyGEqual*)initReify:(id<ORIntVar>)b equiv:(id<ORIntVar>)x geq:(id<ORIntVar>)y
{
   self = [super initORConstraintI];
   _b = b;
   _x = x;
   _y = y;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=> (%@ >= %@)",[self class],self,_b,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifyGEqual:self];
}
-(id<ORIntVar>) b
{
   return _b;
}
-(id<ORIntVar>) x
{
   return _x;
}
-(id<ORIntVar>) y
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_b,_x,_y, nil] autorelease];
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_x];
   [aCoder encodeObject:_y];
}
- (id)initWithCoder:(NSCoder *)aDecoder
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _x = [aDecoder decodeObject];
   _y = [aDecoder decodeObject];
   return self;
}
@end

// ========================================================================================================
// Sums

@implementation ORReifySumBoolEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (reify:%@ sumbool(%@) == %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifySumBoolEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORReifySumBoolGEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (reify:%@ sumbool(%@) >= %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitReifySumBoolGEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORHReifySumBoolEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (hreify:%@ sumbool(%@) == %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitHReifySumBoolEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}

- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORHReifySumBoolGEqc {
   id<ORIntVar>       _b;
   id<ORIntVarArray> _ba;
   ORInt              _c;
}
-(id) init:(id<ORIntVar>)b array:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _b = b;
   _ba = ba;
   _c = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (hreify:%@ sumbool(%@) >= %d)",[self class],self,_b,_ba,_c];
   return buf;
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(id<ORIntVar>) b
{
   return _b;
}
-(ORInt)cst
{
   return _c;
}
-(void)visit:(ORVisitor*)v
{
   [v visitHReifySumBoolGEqualc:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]+1] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_b];
   return ms;
}
- (void)encodeWithCoder:(NSCoder *)aCoder
{
   [super encodeWithCoder:aCoder];
   [aCoder encodeObject:_b];
   [aCoder encodeObject:_ba];
   [aCoder encodeValueOfObjCType:@encode(ORInt) at:&_c];
}
- (id)initWithCoder:(NSCoder *)aDecoder;
{
   self = [super initWithCoder:aDecoder];
   _b = [aDecoder decodeObject];
   _ba= [aDecoder decodeObject];
   [aDecoder decodeValueOfObjCType:@encode(ORInt) at:&_c];
   return self;
}
@end

@implementation ORClause {
   id<ORIntVarArray>  _ba;
   id<ORIntVar>       _tv;
}
-(id)init:(id<ORIntVarArray>)ba eq:(id<ORIntVar>)tv
{
   self = [super initORConstraintI];
   _ba = ba;
   _tv = tv;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (clause(%@) == %@)",[self class],self,_ba,_tv];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitClause:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_tv];
   return ms;
}
-(id<ORIntVar>)targetValue
{
   return _tv;
}
@end

@implementation ORSumBoolEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolEqc*)initSumBool:(id<ORIntVarArray>)ba eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) == %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumBoolEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumBoolNEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolNEqc*)initSumBool:(id<ORIntVarArray>)ba neqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) != %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumBoolNEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORSumBoolLEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;   
}
-(ORSumBoolLEqc*)initSumBool:(id<ORIntVarArray>)ba leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) <= %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumBoolLEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumBoolGEqc {
   id<ORIntVarArray> _ba;
   ORInt             _c;
}
-(ORSumBoolGEqc*)initSumBool:(id<ORIntVarArray>)ba geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ba = ba;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sumbool(%@) >= %d)",[self class],self,_ba,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumBoolGEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ba;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ba count]] autorelease];
   [_ba enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;
}
-(ORSumEqc*)initSum:(id<ORIntVarArray>)ia eqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) == %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumLEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;   
}
-(ORSumLEqc*) initSum:(id<ORIntVarArray>)ia leqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) <= %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumLEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSumGEqc {
   id<ORIntVarArray> _ia;
   ORInt              _c;   
}
-(ORSumGEqc*)initSum:(id<ORIntVarArray>)ia geqi:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@) >= %d)",[self class],self,_ia,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSumGEqualc:self];
}
-(id<ORIntVarArray>)vars
{
   return _ia;
}
-(ORInt)cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORLinearGeq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearGeq*) initLinearGeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst: (ORInt) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitLinearGeq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORLinearLeq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearLeq*) initLinearLeq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst:(ORInt)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitLinearLeq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORLinearEq {
   id<ORIntVarArray> _ia;
   id<ORIntArray>    _coefs;
   ORInt             _c;
}
-(ORLinearEq*) initLinearEq: (id<ORIntVarArray>) ia coef: (id<ORIntArray>) coefs cst:(ORInt) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %d)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(NSUInteger)count
{
   assert([_ia count] == [_coefs count]);
   return [_ia count];
}
-(void)visit: (ORVisitor*) v
{
   [v visitLinearEq: self];
}
-(id<ORIntVarArray>) vars
{
   return _ia;
}
-(id<ORIntArray>) coefs
{
   return _coefs;
}
-(ORInt) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORRealLinearEq {
   id<ORVarArray> _ia;
   id<ORDoubleArray>  _coefs;
   ORDouble _c;
}
-(ORRealLinearEq*) initRealLinearEq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble) c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) == %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearEq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORRealLinearLeq {
   id<ORVarArray> _ia;
   id<ORDoubleArray> _coefs;
   ORDouble _c;
}
-(ORRealLinearLeq*) initRealLinearLeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) <= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearLeq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORRealLinearGeq {
   id<ORVarArray> _ia;
   id<ORDoubleArray> _coefs;
   ORDouble _c;
}
-(id) initRealLinearGeq: (id<ORVarArray>) ia coef: (id<ORDoubleArray>) coefs cst:(ORDouble)c
{
   self = [super initORConstraintI];
   _ia = ia;
   _coefs = coefs;
   _c  = c;
   return self;
   
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (sum(%@,%@) >= %f)",[self class],self,_ia,_coefs,_c];
   return buf;
}
-(void) visit: (ORVisitor*) v
{
   [v visitRealLinearGeq: self];
}
-(id<ORVarArray>) vars
{
   return _ia;
}
-(id<ORDoubleArray>) coefs
{
   return _coefs;
}
-(ORDouble) cst
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_ia count]] autorelease];
   [_ia enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORAlldifferentI {
   id<ORExprArray> _x;
   NSSet*         _av;
}
-(ORAlldifferentI*) initORAlldifferentI: (id<ORExprArray>) x
{
   self = [super initORConstraintI];
   _x = x;
   _av = nil;
   return self;
}
-(void)dealloc
{
   [_av release];
   [super dealloc];
}
-(id<ORExprArray>) array
{
   return _x;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORAlldifferentI: %p IS [ ",self];
   for(ORInt i = [_x low];i <= [_x up];i++) {
      [buf appendFormat:@"%@%c",_x[i],i < [_x up] ? ',' : ' '];
   }
   [buf appendString:@"]>"];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAlldifferent:self];
}
-(NSSet*)allVars
{
   if (_av == nil) {
      NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
      for(id<ORExpr> e in _x)
         [ms addObject:e];
//      [_x enumerateWith:^(id obj, int idx) {
//         [ms addObject:obj];
//      }];
      _av = [ms retain];
   }
   return _av;
}
@end


@implementation ORAmongI {
   id<ORExprArray> _x;
   NSSet*         _av;
   
   id<ORIntSet> _values;
   ORInt _low, _up;
}
-(ORAmongI*) initORAmongI: (id<ORExprArray>) x values:(id<ORIntSet>)values low:(ORInt)low up:(ORInt)up
{
   self = [super initORConstraintI];
   _x = x;
   _av = nil;
   _values = values;
   _low = low;
   _up = up;
   return self;
}
-(void)dealloc
{
   [_av release];
   [super dealloc];
}
-(id<ORExprArray>) array
{
   return _x;
}
-(id<ORIntSet>) values { return _values; }
-(ORInt) low { return _low; }
-(ORInt) up { return _up; }
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORAmongI: %p IS [ ",self];
   for(ORInt i = [_x low];i <= [_x up];i++) {
      [buf appendFormat:@"%@%c",_x[i],i < [_x up] ? ',' : ' '];
   }
   [buf appendString:@"]>"];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAmong:self];
}
-(NSSet*)allVars
{
   if (_av == nil) {
      NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
      for(id<ORExpr> e in _x)
         [ms addObject:e];
      _av = [ms retain];
   }
   return _av;
}
@end


@implementation ORRegularI {
   id<ORIntVarArray>    _x;
   id<ORAutomaton>   _auto;
}
-(id)init:(id<ORIntVarArray>)x  for:(id<ORAutomaton>)a
{
   self = [super initORConstraintI];
   _x = x;
   _auto = a;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORAutomaton>)automaton
{
   return _auto;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORRegularI: %p IS [ ",self];
   for(ORInt i = [_x low];i <= [_x up];i++) {
      [buf appendFormat:@"%@%c",_x[i],i < [_x up] ? ',' : ' '];
   }
   [buf appendString:@"]>"];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRegular:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORCardinalityI
{
   id<ORIntVarArray> _x;
   id<ORIntArray>    _low;
   id<ORIntArray>     _up;
}
-(ORCardinalityI*) initORCardinalityI: (id<ORIntVarArray>) x low: (id<ORIntArray>) low up: (id<ORIntArray>) up
{
   self = [super initORConstraintI];
   _x = x;
   _low = low;
   _up = up;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORIntArray>) low
{
   return _low;
}
-(id<ORIntArray>) up
{
   return _up;
}
-(void)visit:(ORVisitor*)v
{
   [v visitCardinality:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@interface VarCollector : ORNOopVisit {
   NSMutableSet* _theSet;
}
-(id)init:(NSMutableSet*)theSet;
+(NSSet*)collect:(id<ORExpr>)e;
@end

@implementation VarCollector
+(NSSet*)collect:(id<ORExpr>)e
{
   NSMutableSet* rv = [[NSMutableSet alloc] initWithCapacity:4];
   VarCollector* vc = [[VarCollector alloc] init:rv];
   [e visit:vc];
   [vc release];
   return rv;
}
-(id)init:(NSMutableSet*)theSet
{
   self = [super init];
   _theSet = theSet;
   return self;
}
-(void) visitIntVar: (id<ORIntVar>) v
{
   [_theSet addObject:v];
}
-(void) visitBitVar: (id<ORBitVar>) v
{
   [_theSet addObject:v];
}
-(void) visitRealVar: (id<ORRealVar>) v
{
   [_theSet addObject:v];
}
-(void) visitIntVarLitEQView:(id<ORIntVar>)v
{
   [_theSet addObject:v];
}
-(void) visitAffineVar:(id<ORIntVar>) v
{
   [_theSet addObject:v];
}
-(void) visitIntegerI: (id<ORInteger>) e
{}
-(void) visitMutableIntegerI: (id<ORMutableInteger>) e
{}
-(void) visitMutableDouble: (id<ORMutableDouble>) e
{}
-(void) visitDouble: (id<ORDoubleNumber>) e
{}
-(void) visitExprPlusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinusI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMulI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprDivI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprModI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMinI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprMaxI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprNEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprLEqualI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprSumI: (ORExprSumI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprProdI: (ORExprProdI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMinI: (ORExprAggMinI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggMaxI: (ORExprAggMaxI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAbsI:(ORExprAbsI*) e
{
   [[e operand] visit:self];
}
-(void) visitExprSquareI:(ORExprSquareI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprNegateI:(ORExprNegateI*)e
{
   [[e operand] visit:self];
}
-(void) visitExprCstSubI: (ORExprCstSubI*) e
{
   [[e index] visit:self];
}
-(void) visitExprCstDoubleSubI:(ORExprCstDoubleSubI*)e
{
   [[e index] visit:self];
}
-(void) visitExprDisjunctI:(ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprConjunctI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprImplyI: (ORExprBinaryI*) e
{
   [[e left] visit:self];
   [[e right] visit:self];
}
-(void) visitExprAggOrI: (ORExprAggOrI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprAggAndI: (ORExprAggAndI*) e
{
   [[e expr] visit:self];
}
-(void) visitExprVarSubI: (ORExprVarSubI*) e
{
   [[e index] visit:self];
   id<ORIntVarArray> a = [e array];
   for(id<ORIntVar> ak in a)
       [_theSet addObject:ak];
}
-(void) visitExprMatrixVarSubI:(ORExprMatrixVarSubI*)e
{
   [[e index0] visit:self];
   [[e index1] visit:self];
   id<ORIntVarMatrix> m = [e matrix];
   ORInt sz = (ORInt)[m count];
   for(ORInt i=0;i < sz;i++)
      [_theSet addObject:[m  flat:i]];
}
@end

@implementation ORAlgebraicConstraintI {
   id<ORRelation> _expr;
}
-(ORAlgebraicConstraintI*) initORAlgebraicConstraintI: (id<ORRelation>) expr
{
   self = [super initORConstraintI];
   _expr = expr;
   return self;
}
-(id<ORRelation>) expr
{
   return _expr;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORAlgebraicConstraintI : %p(%d) IS %@>",self,[self getId],_expr];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitAlgebraicConstraint:self];
}
-(NSSet*)allVars
{
   NSSet* ms = [[VarCollector collect:_expr] autorelease];
   return ms;
}
@end

@implementation ORSoftAlgebraicConstraintI {
   id<ORVar> _slack;
}
-(ORSoftAlgebraicConstraintI*) initORSoftAlgebraicConstraintI: (id<ORRelation>) expr slack: (id<ORVar>)slack
{
   self = [super initORAlgebraicConstraintI: expr];
   _slack = slack;
   return self;
}
-(id<ORVar>) slack
{
   return _slack;
}
@end

@implementation ORRealWeightedVarI {
   id<ORVar> _x;
   id<ORVar> _z;
   id<ORParameter> _lambda;
}
-(ORRealWeightedVarI*) initRealWeightedVar: (id<ORVar>)x
{
   self = [super initORConstraintI];
   _x = x;
   _z = [ORFactory realVar: [(id<ORExpr>)x tracker]  low:FDMININT up:FDMAXINT];
   _lambda = [[ORRealParamI alloc] initORRealParamI: [(id<ORExpr>)x tracker] initialValue: 0.0]; // TOTRY [ldm] try with param @ 1.
   return self;
}
-(id<ORVar>) z
{
   return _z;
}
-(id<ORVar>)x
{
   return _x;
}
-(id<ORParameter>)weight
{
   return _lambda;
}
-(NSSet*) allVars
{
   return [[NSSet setWithObjects: _x, _z, nil] autorelease];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORFloatWeightedConstraintI : %p(%d) IS %@ = %@ * %@",self,[self getId],_z,_lambda,_x];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitRealWeightedVar:self];
}
@end

@implementation ORTableConstraintI
{
   id<ORIntVarArray> _x;
   id<ORTable> _table;
}
-(ORTableConstraintI*) initORTableConstraintI: (id<ORIntVarArray>) x table: (id<ORTable>) table
{
   self = [super init];
   _x = x;
   _table = table;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(id<ORTable>) table
{
   return _table;
}
-(void)visit:(ORVisitor*)v
{
   [v visitTableConstraint:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORLexLeq {
   id<ORIntVarArray> _x;
   id<ORIntVarArray> _y;
}
-(ORLexLeq*)initORLex:(id<ORIntVarArray>)x leq:(id<ORIntVarArray>)y
{
   self = [super init];
   _x = x;
   _y = y;
   return self;
}
-(id<ORIntVarArray>)x
{
   return _x;
}
-(id<ORIntVarArray>)y
{
   return _y;
}
-(void)visit:(ORVisitor*)v
{
   [v visitLexLeq:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> lexleq(%@,%@)>",[self class],self,_x,_y];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+[_y count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORCircuit {
   id<ORIntVarArray> _x;
}
-(ORCircuit*)initORCircuit:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitCircuit:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> circuit(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORPath {
   id<ORIntVarArray> _x;
}
-(ORPath*) initORPath:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitPath:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> path(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end
   
@implementation ORSubCircuit {
   id<ORIntVarArray> _x;
}
-(ORSubCircuit*)initORSubCircuit:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitSubCircuit:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> subcircuit(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORNoCycleI {
   id<ORIntVarArray> _x;
}
-(id) initORNoCycleI:(id<ORIntVarArray>)x
{
   self = [super initORConstraintI];
   _x = x;
   return self;
}
-(id<ORIntVarArray>) array
{
   return _x;
}
-(void)visit:(ORVisitor*)v
{
   [v visitNoCycle:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> nocycle(%@)>",[self class],self,_x];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORPackOneI {
   id<ORIntVarArray> _item;
   id<ORIntArray>    _itemSize;
   ORInt             _bin;
   id<ORIntVar>      _binSize;
}
-(ORPackOneI*)initORPackOneI:(id<ORIntVarArray>) item itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b binSize: (id<ORIntVar>) binSize
{
   self = [super initORConstraintI];
   _item = item;
   _itemSize = itemSize;
   _bin = b;
   _binSize  = binSize;
   return self;
}
-(void)visit:(ORVisitor*)v
{
   [v visitPackOne:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> packOne(%@,%@,%d,%@)>",[self class],self,_item,_itemSize,_bin,_binSize];
   return buf;
}
-(id<ORIntVarArray>) item
{
   return _item;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(ORInt) bin
{
   return _bin;
}
-(id<ORIntVar>) binSize
{
   return _binSize;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_item count]+1] autorelease];
   [_item enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_binSize];
   return ms;
}
@end

@implementation ORPackingI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>    _itemSize;
   id<ORIntVarArray>     _load;
}
typedef struct _CPPairIntId {
   ORInt        _int;
   id           _id;
} CPPairIntId;

int compareCPPairIntId(const CPPairIntId* r1,const CPPairIntId* r2)
{
   return r2->_int - r1->_int;
}
void sortIntVarInt(id<ORIntVarArray> x,id<ORIntArray> size,id<ORIntVarArray>* sx,id<ORIntArray>* sortedSize)
{
   id<ORIntRange> R = [x range];
   int nb = [R up] - [R low] + 1;
   ORInt low = [R low];
   ORInt up = [R up];
   CPPairIntId* toSort = (CPPairIntId*) alloca(sizeof(CPPairIntId) * nb);
   int k = 0;
   for(ORInt i = low; i <= up; i++)
      toSort[k++] = (CPPairIntId){[size at: i],x[i]};
   qsort(toSort,nb,sizeof(CPPairIntId),(int(*)(const void*,const void*)) &compareCPPairIntId);   
   *sx = [ORFactory intVarArray: [x tracker] range: R with: ^id<ORIntVar>(int i) { return toSort[i - low]._id; }];
   *sortedSize = [ORFactory intArray:[x tracker] range: R with: ^ORInt(ORInt i) { return toSort[i - low]._int; }];
}

-(ORPackingI*)initORPackingI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize load: (id<ORIntVarArray>) load
{
   self = [super initORConstraintI];   
   sortIntVarInt(x,itemSize,&_x,&_itemSize);
   _load     = load;
   return self;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(id<ORIntVarArray>) binSize
{
   return _load;
}
-(void)visit:(ORVisitor*)v
{
   [v visitPacking:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> packing(%@,%@,%@)>",[self class],self,_x,_itemSize,_load];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+[_load count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_load enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORMultiKnapsackI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>           _itemSize;
   id<ORIntArray>           _capacity;
}
-(ORMultiKnapsackI*)initORMultiKnapsackI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize capacity: (id<ORIntArray>) capacity
{
   self = [super initORConstraintI];
   _x = x;
   _itemSize = itemSize;
   _capacity    = capacity;
   return self;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(id<ORIntArray>) capacity
{
   return _capacity;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMultiKnapsack:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> multiknapsack(%@,%@,%@)>",[self class],self,_x,_itemSize,_capacity];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORMultiKnapsackOneI {
   id<ORIntVarArray>        _x;
   id<ORIntArray>           _itemSize;
   ORInt                    _bin;
   ORInt                   _capacity;
}
-(ORMultiKnapsackOneI*)initORMultiKnapsackOneI:(id<ORIntVarArray>) x itemSize: (id<ORIntArray>) itemSize bin: (ORInt) b capacity: (ORInt) capacity
{
   self = [super initORConstraintI];
   _x = x;
   _itemSize = itemSize;
   _bin = b;
   _capacity    = capacity;
   return self;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) itemSize
{
   return _itemSize;
}
-(ORInt) capacity
{
   return _capacity;
}
-(ORInt) bin
{
   return _bin;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMultiKnapsackOne: self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> multiknapsackOne(%@,%@,%d)>",[self class],self,_x,_itemSize,_capacity];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end


@implementation ORMeetAtmostI {
   id<ORIntVarArray>        _x;
   id<ORIntVarArray>        _y;
   ORInt                    _k;
}
-(ORMeetAtmostI*)initORMeetAtmostI:(id<ORIntVarArray>) x and: (id<ORIntVarArray>) y atmost: (ORInt) atmost
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _k = atmost;
   return self;
}
-(id<ORIntVarArray>) x
{
   return _x;
}
-(id<ORIntVarArray>) y
{
   return _y;
}
-(ORInt) atmost
{
   return _k;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMeetAtmost:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> MeetAtmost(%@,%@,%d)>",[self class],self,_x,_y,_k];
   return buf;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [_y enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORKnapsackI {
   id<ORIntVarArray> _x;
   id<ORIntArray>    _w;
   id<ORIntVar>      _c;
}
-(ORKnapsackI*)initORKnapsackI:(id<ORIntVarArray>) x weight:(id<ORIntArray>) w capacity:(id<ORIntVar>)c
{
   self = [super initORConstraintI];
   _x = x;
   _w = w;
   _c = c;
   return self;
}
-(void)visit:(ORVisitor*)v
{
   [v visitKnapsack:self];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> knapsack(%@,%@,%@)>",[self class],self,_x,_w,_c];
   return buf;
}
-(id<ORIntVarArray>) item
{
   return _x;
}
-(id<ORIntArray>) weight
{
   return _w;
}
-(id<ORIntVar>) capacity
{
   return _c;
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   return ms;
}
@end

@implementation ORSoftKnapsackI {
   id<ORVar> _slack;
}
-(ORSoftKnapsackI*) initORSoftKnapsackI:(id<ORIntVarArray>)x weight:(id<ORIntArray>)w capacity:(id<ORIntVar>)c slack:(id<ORVar>)slack
{
   self = [super initORKnapsackI: x weight: w capacity: c];
   if(self) {
      _slack = slack;
   }
   return self;
}

-(id<ORVar>) slack
{
   return _slack;
}
@end

@implementation ORAssignmentI {
   id<ORIntVarArray> _x;
   id<ORIntMatrix> _matrix;
   id<ORIntVar>    _cost;
}
-(ORAssignmentI*)initORAssignment:(id<ORIntVarArray>) x matrix: (id<ORIntMatrix>) matrix cost: (id<ORIntVar>) cost
{
   self = [super initORConstraintI];
   _x = x;
   _matrix = matrix;
   _cost = cost;
   return self;
}
-(id<ORIntVarArray>) x
{
   return _x;
}
-(id<ORIntMatrix>) matrix
{
   return _matrix;
}
-(id<ORIntVar>) cost
{
   return _cost;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitAssignment:self];
}
-(NSSet*)allVars
{
   NSMutableSet* ms = [[[NSMutableSet alloc] initWithCapacity:[_x count]+1] autorelease];
   [_x enumerateWith:^(id obj, int idx) {
      [ms addObject:obj];
   }];
   [ms addObject:_cost];
   return ms;
}
@end

@implementation ORObjectiveFunctionI
-(ORObjectiveFunctionI*) initORObjectiveFunctionI
{
   self = [super init];
   return self;
}
-(id<ORObjectiveValue>) primalValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method primalValue/0 not implemented"];
}
-(id<ORObjectiveValue>) dualValue
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method dualValue/0 not implemented"];
}
-(id<ORObjectiveValue>) primalBound
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method primalBound/0 not implemented"];
}
-(id<ORObjectiveValue>) dualBound
{
   @throw [[ORExecutionError alloc] initORExecutionError: "ORObjectiveFunctionI: Method dualBound/0 not implemented"];
}
@end

@implementation ORObjectiveFunctionVarI
-(ORObjectiveFunctionVarI*) initORObjectiveFunctionVarI: (id<ORVar>) x
{
   self = [super init];
   _var = x;
   return self;
}
-(id<ORVar>) var
{
   return _var;
}
-(id<ORObjectiveValue>)value
{
  return NULL;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
@end

@implementation ORObjectiveValueIntI
-(id) initObjectiveValueIntI: (ORInt) pb minimize: (ORBool) b
{
   self = [super init];
   _value = pb;
   _pBound = pb;
   _direction = b ? 1 : -1;
   return self;
}
-(ORInt) value
{
   return _value;
}
-(ORInt) intValue
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORInt) primal
{
   return _pBound;
}
-(ORDouble) key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"%d",_value];
   return buf;
}
-(ORBool)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return _value == [((ORObjectiveValueIntI*)object) value];
   } else return NO;
}
- (NSUInteger)hash
{
   return _value;
}
-(id<ORObjectiveValue>) best: (ORObjectiveValueIntI*) other
{
   if ([self key] <= [other key])
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: _value minimize: _direction == 1];
   else
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [other value] minimize: _direction == 1];
}
-(NSComparisonResult) compare: (ORObjectiveValueIntI*) other
{
   ORInt mykey = [self key];
   ORInt okey = [other key];
   if (mykey < okey)
      return NSOrderedAscending;
   else if (mykey == okey)
      return NSOrderedSame;
   else
      return NSOrderedDescending;
}
@end

@implementation ORObjectiveValueRealI
-(id) initObjectiveValueRealI: (ORDouble) pb minimize: (ORBool) b
{
   self = [super init];
   _value = pb;
   _pBound = pb;
   _direction = b ? 1 : -1;
   return self;
}
-(ORDouble) value
{
   return _value;
}
-(ORDouble) doubleValue
{
   return _value;
}
-(ORDouble) primal
{
   return _pBound;
}
-(ORDouble) key
{
   return _value * _direction;
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   //   [buf appendFormat:@"%s(%d)",_direction==1 ? "min" : "max",_value];
   [buf appendFormat:@"%f",_value];
   return buf;
}

-(ORBool)isEqual:(id)object
{
   if ([object isKindOfClass:[self class]]) {
      return _value == [((ORObjectiveValueRealI*)object) value];
   } else return NO;
}

- (NSUInteger) hash
{
   return _value;
}

-(id<ORObjectiveValue>) best: (ORObjectiveValueRealI*) other
{
   if ([self key] <= [other key])
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: _value minimize: _direction == 1];
   else
      return [[ORObjectiveValueIntI alloc] initObjectiveValueIntI: [other value] minimize: _direction == 1];
}

-(NSComparisonResult) compare: (ORObjectiveValueRealI*) other
{
   ORFloat mykey = [self key];
   ORFloat okey = [other key];
   if (mykey < okey)
      return -1;
   else if (mykey == okey)
      return 0;
   else
      return 1;
}
@end


@implementation ORObjectiveFunctionExprI
-(ORObjectiveFunctionExprI*) initORObjectiveFunctionExprI: (id<ORExpr>) e
{
   self = [super init];
   _expr = e;
   return self;
}
-(id<ORExpr>) expr
{
   return _expr;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionExpr: self];
}
@end

@implementation ORObjectiveFunctionLinearI
-(ORObjectiveFunctionLinearI*) initORObjectiveFunctionLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
   self = [super init];
   _array = array;
   _coef = coef;
   return self;
}
-(id<ORVarArray>) array
{
   return _array;
}
-(id<ORDoubleArray>) coef
{
   return _coef;
}
-(void) visit: (ORVisitor*) visitor
{
   [visitor visitObjectiveFunctionLinear: self];
}
@end

@implementation ORMinimizeVarI
-(ORMinimizeVarI*) initORMinimizeVarI: (id<ORVar>) x
{
   self = [super initORObjectiveFunctionVarI: x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeVarI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeVarI: %p  --> %@> ",self,_var];
   return buf;
}
-(void)visit:(ORVisitor*) v
{
   [v visitMinimizeVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
@end

@implementation ORMaximizeVarI
-(ORMaximizeVarI*) initORMaximizeVarI:(id<ORVar>) x
{
   self = [super initORObjectiveFunctionVarI:x];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeVarI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*)description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeVarI: %p  --> %@> ",self,_var];
   return buf;
}
-(void)visit:(ORVisitor*) v
{
   [v visitMaximizeVar:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_var, nil] autorelease];
}
@end

@implementation ORMaximizeExprI
-(ORMaximizeExprI*) initORMaximizeExprI:(id<ORExpr>) e
{
   self = [super initORObjectiveFunctionExprI: e];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeExprI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeExprI: %p  --> %@> ",self,_expr];
   return buf;
}
-(void) visit:(ORVisitor*)v
{
   [v visitMaximizeExpr:self];
}
@end

@implementation ORMinimizeExprI
-(ORMinimizeExprI*) initORMinimizeExprI:(id<ORExpr>) e
{
   self = [super initORObjectiveFunctionExprI: e];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeExprI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeExprI: %p  --> %@> ",self,_expr];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMinimizeExpr:self];
    //[v visitMinimizeVar: self];
}
@end

@implementation ORMaximizeLinearI
-(ORMaximizeLinearI*) initORMaximizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
   self = [super initORObjectiveFunctionLinearI: array coef: coef];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMaximizeLinearI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMaximizeLinearI: %p  --> %@ %@> ",self,_array,_coef];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMaximizeLinear:self];
}
@end

@implementation ORMinimizeLinearI
-(ORMinimizeLinearI*) initORMinimizeLinearI: (id<ORVarArray>) array coef: (id<ORDoubleArray>) coef
{
   self = [super initORObjectiveFunctionLinearI: array coef: coef];
   return self;
}
-(void)dealloc
{
   NSLog(@"ORMinimizeLinearI dealloc'd (%p)...",self);
   [super dealloc];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<ORMinimizeLinearI: %p  --> %@ %@> ",self,_array,_coef];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitMinimizeLinear:self];
}
-(id<ORObjectiveValue>) value
{
   return NULL;
}
@end


@implementation ORBitEqualAt {
   id<ORBitVar>    _x;
   ORInt         _bit;
   ORInt         _val;
}
-(ORBitEqualAt*)init:(id<ORBitVar>)x at:(ORInt)k with:(ORInt)c
{
   self = [super initORConstraintI];
   _x  = x;
   _bit = k;
   _val = c;
   return self;
}
-(id<ORBitVar>)left
{
   return _x;
}
-(ORInt)cst
{
   return _val;
}
-(ORInt)bit {
   return _bit;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@[%d] == %d)",[self class],self,_x,_bit,_val];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualAt:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}
@end

@implementation ORBitEqualc {
   id<ORBitVar> _x;
   ORInt        _c;
}
-(ORBitEqualc*)init:(id<ORBitVar>)x eqc:(ORInt)c
{
   self = [super initORConstraintI];
   _x = x;
   _c = c;
   return self;
}
-(id<ORBitVar>)left
{
   return _x;
}
-(ORInt)cst
{
   return _c;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %d)",[self class],self,_x,_c];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualc:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,nil] autorelease];
}

@end

@implementation ORBitEqual {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitEqual*)initORBitEqual: (id<ORBitVar>) x eq: (id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitOr {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitOr*)initORBitOr: (id<ORBitVar>) x bor:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ | %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitOr:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitAnd {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitAnd*)initORBitAnd: (id<ORBitVar>) x band:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ & %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitAnd:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitNot {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitNot*)initORBitNot: (id<ORBitVar>) x bnot: (id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ ~ %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNot:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitXor {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitXor*)initORBitXor: (id<ORBitVar>) x bxor:(id<ORBitVar>) y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ ^ %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitXor:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitShiftL {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftL*)initORBitShiftL: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <<%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftL:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftL_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftL_BV*)initORBitShiftL_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ << %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftL_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
@end

@implementation ORBitShiftR {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftR*)initORBitShiftR: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ >>%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftR:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftR_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftR_BV*)initORBitShiftR_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ >> %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftR_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
@end

@implementation ORBitShiftRA {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitShiftRA*)initORBitShiftRA: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ >>a %d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftRA:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitShiftRA_BV {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _places;
}
-(ORBitShiftRA_BV*)initORBitShiftRA_BV: (id<ORBitVar>) x by:(id<ORBitVar>) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(id<ORBitVar>) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ >>a %@ = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitShiftRA_BV:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_places, nil] autorelease];
}
@end

@implementation ORBitRotateL {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   ORInt _places;
}
-(ORBitRotateL*)initORBitRotateL: (id<ORBitVar>) x by:(ORInt) p eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _places = p;
   return self;
}
-(ORInt) places
{
   return _places;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <<<%d = %@)",[self class],self,_x,_places,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitRotateL:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitSum {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _ci;
   id<ORBitVar> _z;
   id<ORBitVar> _co;
}
-(ORBitSum*)initORBitSum: (id<ORBitVar>) x plus:(id<ORBitVar>)y in:(id<ORBitVar>)ci eq:(id<ORBitVar>)z out:(id<ORBitVar>)co
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _ci = ci;
   _z = z;
   _co = co;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) in
{
   return _ci;
}
-(id<ORBitVar>) out
{
   return _co;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_ci,_z,_co, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ + %@ [cin %@] = %@ [cout %@])",[self class],self,_x,_y,_ci,_z,_co];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSum:self];
}
@end

@implementation ORBitNegative{
   id<ORBitVar> _x;
   id<ORBitVar> _y;

}
-(ORBitNegative*)initORBitNegative: (id<ORBitVar>) x eq:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) res
{
   return _y;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (-%@ = %@ )",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNegative:self];
}
@end


@implementation ORBitSubtract {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSubtract*)initORBitSubtract: (id<ORBitVar>) x minus:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ - %@ = %@ )",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSubtract:self];
}
@end

@implementation ORBitMultiply {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitMultiply*)initORBitMultiply: (id<ORBitVar>) x times:(id<ORBitVar>)y eq:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ * %@ = %@ )",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitMultiply:self];
}
@end


@implementation ORBitDivide {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _q;
   id<ORBitVar> _r;
}
-(ORBitDivide*)initORBitDivide: (id<ORBitVar>) x dividedby:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _q = q;
   _r = r;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _q;
}
-(id<ORBitVar>) rem
{
   return _r;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_q, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ / %@ = %@)",[self class],self,_x,_y,_q];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitDivide:self];
}
@end

@implementation ORBitDivideSigned {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _q;
   id<ORBitVar> _r;
}
-(ORBitDivideSigned*)initORBitDivideSigned: (id<ORBitVar>) x dividedby:(id<ORBitVar>)y eq:(id<ORBitVar>)q rem:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _q = q;
   _r = r;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _q;
}
-(id<ORBitVar>) rem
{
   return _r;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_q, nil] autorelease];
}

-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ / %@ = %@)",[self class],self,_x,_y,_q];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitDivideSigned:self];
}
@end

@implementation ORBitIf {
   id<ORBitVar> _w;
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitIf*)initORBitIf: (id<ORBitVar>)w trueIf:(id<ORBitVar>)x equals:(id<ORBitVar>)y zeroIfXEquals:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _w = w;
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _w;
}
-(id<ORBitVar>) trueIf
{
   return _x;
}
-(id<ORBitVar>) equals
{
   return _y;
}
-(id<ORBitVar>) zeroIfXEquals
{
   return _z;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ true if (x=%@)  equals %@ and false if x equals %@.])",[self class],self,_w,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitIf:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_w,_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitCount {
   id<ORBitVar> _x;
   id<ORIntVar> _p;
}
-(ORBitCount*)initORBitCount: (id<ORBitVar>) x count:(id<ORIntVar>)p
{
   self = [super initORConstraintI];
   _x = x;
   _p = p;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _p;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_p, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (| %@ |  = %@ )",[self class],self,_x,_p];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitCount:self];
}
@end

@implementation ORBitChannel {
   id<ORBitVar>  _x;
   id<ORIntVar> _xc;
}
-(ORBitChannel*)init: (id<ORBitVar>) x channel:(id<ORIntVar>)xc
{
   self = [super initORConstraintI];
   _x = x;
   _xc = xc;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORIntVar>) right
{
   return _xc;
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_xc, nil] autorelease];
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (Natural( %@ ) = %@ )",[self class],self,_x,_xc];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitChannel:self];
}
@end

@implementation ORBitZeroExtend {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitZeroExtend*)initORBitZeroExtend:(id<ORBitVar>)x extendTo:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (0...0%@ = %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitZeroExtend:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitSignExtend {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
}
-(ORBitSignExtend*)initORBitSignExtend:(id<ORBitVar>)x extendTo:(id<ORBitVar>)y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (+/-...+/-%@ = %@)",[self class],self,_x,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSignExtend:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitExtract {
   id<ORBitVar> _x;
   ORUInt _lsb;
   ORUInt _msb;
   id<ORBitVar> _y;
}
-(ORBitExtract*)initORBitExtract: (id<ORBitVar>) x from:(ORUInt)lsb to:(ORUInt)msb eq:(id<ORBitVar>) y
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _lsb = lsb;
   _msb = msb;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(ORUInt) lsb
{
   return _lsb;
}
-(ORUInt) msb
{
   return _msb;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ from %i to %i = %@)",[self class],self,_x,_lsb,_msb,_y];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitExtract:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y, nil] autorelease];
}
@end

@implementation ORBitConcat {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitConcat*)initORBitConcat: (id<ORBitVar>) x concat:(id<ORBitVar>) y eq:(id<ORBitVar>) z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@::%@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitConcat:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z,nil] autorelease];
}
@end

@implementation ORBitLogicalEqual {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLogicalEqual*)initORBitLogicalEqual: (id<ORBitVar>) x EQ:(id<ORBitVar>) y eval:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ = %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalEqual:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitLT {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLT*)initORBitLT: (id<ORBitVar>) x LT:(id<ORBitVar>) y eval:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ < %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLT:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitLE {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitLE*)initORBitLE: (id<ORBitVar>) x LE:(id<ORBitVar>) y eval:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <= %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitSLE {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSLE*)initORBitSLE: (id<ORBitVar>) x SLE:(id<ORBitVar>) y eval:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <=(signed) %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSLE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end

@implementation ORBitSLT {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _z;
}
-(ORBitSLT*)initORBitSLT: (id<ORBitVar>) x SLT:(id<ORBitVar>) y eval:(id<ORBitVar>)z
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _z = z;
   return self;
}
-(id<ORBitVar>) res
{
   return _z;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ <(signed) %@ evaluates to %@)",[self class],self,_x,_y,_z];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitSLT:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_z, nil] autorelease];
}
@end


@implementation ORBitITE {
   id<ORBitVar> _i;
   id<ORBitVar> _t;
   id<ORBitVar> _e;
   id<ORBitVar> _r;
}
-(ORBitITE*)initORBitITE: (id<ORBitVar>)i then:(id<ORBitVar>)t else:(id<ORBitVar>)e result:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _i = i;
   _t = t;
   _e = e;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _i;
}
-(id<ORBitVar>) right1
{
   return _t;
}
-(id<ORBitVar>) right2
{
   return _e;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (if %@ then %@ else %@) evaluates to %@",[self class],self,_i,_t,_e,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitITE:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_i,_t,_e,_r, nil] autorelease];
}
@end

@implementation ORBitLogicalAnd {
   id<ORBitVarArray> _x;
   id<ORBitVar> _r;
}
-(ORBitLogicalAnd*)initORBitLogicalAnd:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVarArray>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (&& %@[0..n]) evaluates to %@",[self class],self,_x[0],_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalAnd:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitLogicalOr {
   id<ORBitVarArray> _x;
   id<ORBitVar> _r;
}
-(ORBitLogicalOr*)initORBitLogicalOr:(id<ORBitVarArray>)x eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVarArray>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (|| %@[0..n]) evaluates to %@",[self class],self,_x[0],_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitLogicalOr:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitOrb {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitOrb*)initORBitOrb: (id<ORBitVar>) x bor:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ | %@ = %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitOrb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end

@implementation ORBitNotb {
   id<ORBitVar> _x;
   id<ORBitVar> _r;
}
-(ORBitNotb*)initORBitNotb: (id<ORBitVar>) x  eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (~ %@  = %@)",[self class],self,_x,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitNotb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_r, nil] autorelease];
}
@end

@implementation ORBitEqualb {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitEqualb*)initORBitEqualb: (id<ORBitVar>) x equal:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ => %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitEqualb:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end


@implementation ORBitDistinct {
   id<ORBitVar> _x;
   id<ORBitVar> _y;
   id<ORBitVar> _r;
}
-(ORBitDistinct*)initORBitDistinct: (id<ORBitVar>) x distinctFrom:(id<ORBitVar>) y eval:(id<ORBitVar>)r
{
   self = [super initORConstraintI];
   _x = x;
   _y = y;
   _r = r;
   return self;
}
-(id<ORBitVar>) res
{
   return _r;
}
-(id<ORBitVar>) left
{
   return _x;
}
-(id<ORBitVar>) right
{
   return _y;
}
-(NSString*) description
{
   NSMutableString* buf = [[[NSMutableString alloc] initWithCapacity:64] autorelease];
   [buf appendFormat:@"<%@ : %p> -> (%@ == %@ => %@)",[self class],self,_x,_y,_r];
   return buf;
}
-(void)visit:(ORVisitor*)v
{
   [v visitBitDistinct:self];
}
-(NSSet*)allVars
{
   return [[[NSSet alloc] initWithObjects:_x,_y,_r, nil] autorelease];
}
@end


