/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

#import <ORFoundation/ORFoundation.h>
#import <ORFoundation/ORSemBDSController.h>
#import <ORFoundation/ORSemDFSController.h>
#import <ORModeling/ORModeling.h>
#import <ORModeling/ORModelTransformation.h>
#import <ORProgram/LPProgram.h>
#import <objcp/CPFactory.h>
#import "../ORModeling/ORLinearize.h"
#import "../ORModeling/ORFlatten.h"
#import <ORProgram/ORRunnable.h>
#import "ORParallelRunnable.h"
#import "ORColumnGeneration.h"
#import "LPRunnable.h"
#import "CPRunnable.h"
#import "ORLagrangeRelax.h"
#import "ORLagrangianTransform.h"
#import "SetCoveringInstanceParser.h"


int main (int argc, const char * argv[])
{
    id<ORModel> m = [ORFactory createModel];
    NSString* execPath = [NSString stringWithFormat: @"%s", argv[0]];
    NSString* basePath = [execPath stringByDeletingLastPathComponent];
    NSString* path = [NSString pathWithComponents: [NSArray arrayWithObjects:basePath,
                                                    @"simple.msc", nil]];
                                                    //@"frb30-15-1.msc", nil]];
    NSLog(@"path: %@", path);
    SetCoveringInstanceParser* parser = [[SetCoveringInstanceParser alloc] init];
    SetCoveringInstance* instance = [parser parseInstanceFile: m path: path];
    id<ORIntRange> setRange = RANGE(m, 0, (ORInt)instance.sets.count-1);
    id<ORIntRange> universe = RANGE(m, 1, (ORInt)instance.universe);
    id<ORIntVarArray> s = [ORFactory intVarArray: m range: setRange domain: RANGE(m, 0, 1)];
    
    [m minimize: Sum(m, i, setRange, s[i])];
    for(ORInt n = [universe low]; n <= [universe up]; n++) {
        id<ORExpr> expr = [ORFactory sum: m over: setRange
                                suchThat: ^bool(ORInt i) { return [[instance.sets at: i] member: n]; }
                                      of: ^id<ORExpr>(ORInt i) { return [s at: i]; }];
        [m add: [expr geq: @1]];
    }
    
    ORLagrangianTransform* t = [[ORLagrangianTransform alloc] init];
    id<ORParameterizedModel> lagrangeModel = [t apply: m relaxing: [m constraints]];
    id<ORRunnable> lr = [[ORLagrangeRelax alloc] initWithModel: lagrangeModel];
    [lr run];
    
    NSLog(@"lower bound: %f", [(ORLagrangeRelax*)lr bestBound]);
    return 0;
}
