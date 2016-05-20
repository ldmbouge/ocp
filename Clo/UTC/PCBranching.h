#import <ORProgram/ORProgram.h>

@interface PCBranching : NSObject
-(id)init:(id<ORRelaxation>)relax over:(id<ORIntVarArray>)vars program:(id<CPCommonProgram>)p;
-(void)recordVar:(id<ORVar>)x low:(double)low;
-(void)recordVar:(id<ORVar>)x up:(double)up;
-(void)measureDown:(id<ORVar>)x for:(ORClosure)cl;
-(void)measureUp:(id<ORVar>)x for:(ORClosure)cl;
-(ORInt)selectVar:(id<ORIntVarArray>)x;
-(void)branchOn:(id<ORIntVarArray>)x;
@end