//
//  ORLagrangeRelax.h
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import <Foundation/Foundation.h>
#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORRunnablePiping.h>

@protocol ORLagrangeRelax <ORRunnable>
-(void) setUpperBound: (ORFloat)upperBound;
-(ORFloat) upperBound;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
@end

@interface ORSubgradientTemplate : ORPipedRunnable<ORLagrangeRelax, ORLowerBoundStreamProducer>
-(id) initSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat) ub;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) setSolverTimeLimit: (ORFloat)limit;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
-(void) setUpperBound: (ORFloat)upperBound;
-(ORFloat) upperBound;
@end

@interface ORSurrogateTemplate : ORSubgradientTemplate
-(id) initWithSurrogate:(id<ORParameterizedModel>)m bound: (ORFloat) ub;
@end

@interface MIPSubgradient : ORSubgradientTemplate
@end

@interface CPSubgradient : ORSubgradientTemplate
@end

@interface MIPSurrogate : ORSurrogateTemplate
@end

@interface CPSurrogate : ORSurrogateTemplate
@end

@interface ORFactory(ORLagrangeRelax)
+(id<ORLagrangeRelax>) MIPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub;
+(id<ORLagrangeRelax>) CPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub;
+(id<ORLagrangeRelax>) MIPSurrogate: (id<ORParameterizedModel>)m bound: (ORFloat)ub;
@end
