//
//  ORSignature.m
//  Clo
//
//  Created by Daniel Fontaine on 4/21/13.
//
//

#import "ORSignature.h"

@implementation ORSignatureI

-(ORBool) matches: (id<ORSignature>)sig {
    return YES;
}

@synthesize isComplete;
@synthesize providesLowerBound;
@synthesize providesLowerBoundPool;
@synthesize providesLowerBoundStream;
@synthesize providesUpperBound;
@synthesize providesUpperBoundPool;
@synthesize providesUpperBoundStream;
@synthesize providesSolutionStream;
@synthesize providesColumn;
@synthesize providesConstraint;
@synthesize providesConstraintSet;
@synthesize acceptsLowerBound;
@synthesize acceptsLowerBoundPool;
@synthesize acceptsLowerBoundStream;
@synthesize acceptsUpperBound;
@synthesize acceptsUpperBoundPool;
@synthesize acceptsUpperBoundStream;
@synthesize acceptsSolutionStream;
@synthesize acceptsColumn;
@synthesize acceptsConstraint;
@synthesize acceptsConstraintSet;

@end

@implementation ORMutableSignatureI
-(id) init
{
    if((self = [super init]) != nil) {
        [self clear];
    }
    return self;
}

-(id) initFromSignature: (id<ORSignature>)sig
{
    if((self = [super init]) != nil) {
        [self copy: sig];
    }
    return self;
}

-(void) copy: (id<ORSignature>)sig
{
    isComplete = [sig isComplete];
    providesLowerBound = [sig providesLowerBound];
    providesLowerBoundPool = [sig providesLowerBoundPool];
    providesLowerBoundStream = [sig providesLowerBoundStream];
    providesUpperBound = [sig providesUpperBound];
    providesUpperBoundPool = [sig providesUpperBoundPool];
    providesUpperBoundStream = [sig providesUpperBoundStream];
    providesSolutionStream = [sig providesSolutionStream];
    providesColumn = [sig providesColumn];
    providesConstraint = [sig providesConstraint];
    providesConstraintSet = [sig providesConstraintSet];
    acceptsLowerBound = [sig acceptsLowerBound];
    acceptsLowerBoundPool = [sig acceptsLowerBoundPool];
    acceptsLowerBoundStream = [sig acceptsLowerBoundStream];
    acceptsUpperBound = [sig acceptsUpperBound];
    acceptsUpperBoundPool = [sig acceptsUpperBoundPool];
    acceptsUpperBoundStream = [sig acceptsUpperBoundStream];
    acceptsSolutionStream = [sig acceptsSolutionStream];
    acceptsColumn = [sig acceptsColumn];
    acceptsConstraint = [sig acceptsConstraint];
    acceptsConstraintSet = [sig acceptsConstraintSet];
}

-(void) clear {
    isComplete = NO;
    providesLowerBound = NO;
    providesLowerBoundPool = NO;
    providesLowerBoundStream = NO;
    providesUpperBound = NO;
    providesUpperBoundPool = NO;
    providesUpperBoundStream = NO;
    providesSolutionStream = NO;
    providesColumn = NO;
    providesConstraint = NO;
    providesConstraintSet = NO;
    acceptsLowerBound = NO;
    acceptsLowerBoundPool = NO;
    acceptsLowerBoundStream = NO;
    acceptsUpperBound = NO;
    acceptsUpperBoundPool = NO;
    acceptsUpperBoundStream = NO;
    acceptsSolutionStream = NO;
    acceptsColumn = NO;
    acceptsConstraint = NO;
    acceptsConstraintSet = NO;
}

-(ORMutableSignatureI*) complete { isComplete = YES; return self; }
-(ORMutableSignatureI*) upperOut { providesUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamOut { providesUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolOut { providesUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerOut { providesLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamOut { providesLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolOut { providesLowerBoundPool = YES; return self; }
-(ORMutableSignatureI*) solutionStreamOut { providesSolutionStream = YES; return self; }
-(ORMutableSignatureI*) columnOut { providesColumn = YES; return self; }
-(ORMutableSignatureI*) constraintOut { providesConstraint = YES; return self; }
-(ORMutableSignatureI*) constraintSetOut { providesConstraintSet = YES; return self; }
-(ORMutableSignatureI*) upperIn { acceptsUpperBound = YES; return self; }
-(ORMutableSignatureI*) upperStreamIn { acceptsUpperBoundStream = YES; return self; }
-(ORMutableSignatureI*) upperPoolIn { acceptsUpperBoundPool = YES; return self; }
-(ORMutableSignatureI*) lowerIn { acceptsLowerBound = YES; return self; }
-(ORMutableSignatureI*) lowerStreamIn { acceptsLowerBoundStream = YES; return self; }
-(ORMutableSignatureI*) lowerPoolIn { acceptsLowerBoundPool = YES; return self; }
-(ORMutableSignatureI*) solutionStreamIn { acceptsSolutionStream = YES; return self; }
-(ORMutableSignatureI*) columnIn { acceptsColumn = YES; return self; }
-(ORMutableSignatureI*) constraintIn { acceptsConstraint = YES; return self; }
-(ORMutableSignatureI*) constraintSetIn { acceptsConstraintSet = YES; return self; }
@end

@implementation ORFactory(ORSignature)
+(id<ORSignature>) createSignature: (NSString*)sigString {
    ORMutableSignatureI* sig = [[ORMutableSignatureI alloc] init];
    sig = [sig valueForKeyPath: sigString];
    return sig;
}
@end

