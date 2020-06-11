//
//  ORLagrangeRelax.h
//  Clo
//
//  Created by Daniel Fontaine on 8/28/13.
//
//

#import <ORFoundation/ORFoundation.h>
#import <ORModeling/ORModeling.h>
#import <ORProgram/ORRunnablePiping.h>

@protocol ORLagrangeRelax <ORRunnable>
-(void) setUpperBound: (ORFloat)upperBound;
-(ORFloat) upperBound;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
-(void) setSolverTimeLimit: (ORFloat)limit;
-(void) setTimeLimit:(ORFloat)secs;
-(ORInt) iterations;
@end

@interface ORSubgradientTemplate : ORPipedRunnable<ORLagrangeRelax, ORLowerBoundStreamProducer>
-(id) initSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat) ub;
-(id<ORSignature>) signature;
-(id<ORModel>) model;
-(void) run;
-(void) setSolverTimeLimit: (ORFloat)limit;
-(void) setTimeLimit:(ORFloat)secs;
-(void) setAgility: (ORFloat)val;
-(ORFloat) bestBound;
-(id<ORSolution>) bestSolution;
-(void) setUpperBound: (ORFloat)upperBound;
-(ORFloat) upperBound;
-(ORFloat) runtime;
+(NSMutableArray*) autosplitVariables: (NSArray*)vars constraints: (NSArray*)cstrs;
@end

@interface ORSurrogateTemplate : ORSubgradientTemplate
-(id) initWithSurrogate:(id<ORParameterizedModel>)m bound: (ORFloat) ub;
@end

@interface MIPSubgradient : ORSubgradientTemplate
@end

@interface CPSubgradient : ORSubgradientTemplate {
    void(^_search)(id<CPCommonProgram>);
}
-(id) initSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat) ub search: (void(^)(id<CPCommonProgram>))search;
@end

@interface MIPSurrogate : ORSurrogateTemplate
@end

@interface CPSurrogate : ORSurrogateTemplate
@end

@interface ORFactory(ORLagrangeRelax)
+(id<ORLagrangeRelax>) MIPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub;
+(id<ORLagrangeRelax>) CPSubgradient: (id<ORParameterizedModel>)m bound: (ORFloat)ub search: (void(^)(id<CPCommonProgram>))search;
+(id<ORLagrangeRelax>) MIPSurrogate: (id<ORParameterizedModel>)m bound: (ORFloat)ub;
@end
