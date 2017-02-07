//
//  ORSignature.h
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import <ORUtilities/ORUtilities.h>
#import <ORFoundation/ORFactory.h>

@protocol ORSignature<NSObject>
-(ORBool) matches: (id<ORSignature>)sig;
-(ORBool) isComplete;
-(ORBool) providesUpperBound;
-(ORBool) providesUpperBoundStream;
-(ORBool) providesLowerBound;
-(ORBool) providesLowerBoundStream;
-(ORBool) providesLowerBoundPool;
-(ORBool) providesUpperBoundPool;
-(ORBool) providesSolutionStream;
-(ORBool) providesColumn;
-(ORBool) providesConstraint;
-(ORBool) providesConstraintSet;
-(ORBool) acceptsUpperBound;
-(ORBool) acceptsUpperBoundStream;
-(ORBool) acceptsLowerBound;
-(ORBool) acceptsLowerBoundStream;
-(ORBool) acceptsLowerBoundPool;
-(ORBool) acceptsUpperBoundPool;
-(ORBool) acceptsSolutionStream;
-(ORBool) acceptsColumn;
-(ORBool) acceptsConstraint;
-(ORBool) acceptsConstraintSet;
@end

@interface ORSignatureI : NSObject<ORSignature> {
@protected
    bool isComplete;
    bool providesUpperBound;
    bool providesUpperBoundStream;
    bool providesLowerBound;
    bool providesLowerBoundStream;
    bool providesLowerBoundPool;
    bool providesUpperBoundPool;
    bool providesSolutionStream;
    bool providesColumn;
    bool providesConstraint;
    bool providesConstraintSet;
    bool acceptsUpperBound;
    bool acceptsUpperBoundStream;
    bool acceptsLowerBound;
    bool acceptsLowerBoundStream;
    bool acceptsLowerBoundPool;
    bool acceptsUpperBoundPool;
    bool acceptsSolutionStream;
    bool acceptsColumn;
    bool acceptsConstraint;
    bool acceptsConstraintSet;
}
-(ORBool) matches: (id<ORSignature>)sig;
@property(readonly) bool isComplete;
@property(readonly) bool providesUpperBound;
@property(readonly) bool providesUpperBoundStream;
@property(readonly) bool providesLowerBound;
@property(readonly) bool providesLowerBoundStream;
@property(readonly) bool providesLowerBoundPool;
@property(readonly) bool providesUpperBoundPool;
@property(readonly) bool providesSolutionStream;
@property(readonly) bool providesColumn;
@property(readonly) bool providesConstraint;
@property(readonly) bool providesConstraintSet;
@property(readonly) bool acceptsUpperBound;
@property(readonly) bool acceptsUpperBoundStream;
@property(readonly) bool acceptsLowerBound;
@property(readonly) bool acceptsLowerBoundStream;
@property(readonly) bool acceptsLowerBoundPool;
@property(readonly) bool acceptsUpperBoundPool;
@property(readonly) bool acceptsSolutionStream;
@property(readonly) bool acceptsColumn;
@property(readonly) bool acceptsConstraint;
@property(readonly) bool acceptsConstraintSet;
@end

@interface ORMutableSignatureI : ORSignatureI
-(id) init;
-(id) initFromSignature: (id<ORSignature>)sig;
-(void) copy: (id<ORSignature>)sig;
-(void) compose: (id<ORSignature>)sig;
-(void) clear;
-(ORMutableSignatureI*) complete;
-(ORMutableSignatureI*) upperOut;
-(ORMutableSignatureI*) upperStreamOut;
-(ORMutableSignatureI*) upperPoolOut;
-(ORMutableSignatureI*) lowerOut;
-(ORMutableSignatureI*) lowerStreamOut;
-(ORMutableSignatureI*) lowerPoolOut;
-(ORMutableSignatureI*) solutionStreamOut;
-(ORMutableSignatureI*) columnOut;
-(ORMutableSignatureI*) constraintOut;
-(ORMutableSignatureI*) constraintSetOut;
-(ORMutableSignatureI*) upperIn;
-(ORMutableSignatureI*) upperStreamIn;
-(ORMutableSignatureI*) upperPoolIn;
-(ORMutableSignatureI*) lowerIn;
-(ORMutableSignatureI*) lowerStreamIn;
-(ORMutableSignatureI*) lowerPoolIn;
-(ORMutableSignatureI*) solutionStreamIn;
-(ORMutableSignatureI*) columnIn;
-(ORMutableSignatureI*) constraintIn;
-(ORMutableSignatureI*) constraintSetIn;
@end

@interface ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString;
@end

