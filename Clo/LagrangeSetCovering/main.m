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
#import "SetCoveringInstanceParser.h"

int main (int argc, const char * argv[])
{
    id<ORModel> m = [ORFactory createModel];
    NSString* execPath = [NSString stringWithFormat: @"%s", argv[0]];
    NSString* basePath = [execPath stringByDeletingLastPathComponent];
    NSString* path = [NSString pathWithComponents: [NSArray arrayWithObjects:
                      basePath, @"frb30-15-1.msc", nil]];
    NSLog(@"path: %@", path);
    SetCoveringInstanceParser* parser = [[SetCoveringInstanceParser alloc] init];
    SetCoveringInstance* instance = [parser parseInstanceFile: m path: path];
    id<ORIntRange> setRange = RANGE(m, 0, (ORInt)instance.sets.count-1);
    id<ORIntRange> universe = RANGE(m, 1, (ORInt)instance.universe);
    id<ORIntVarArray> s = [ORFactory intVarArray: m range: setRange domain: RANGE(m, 0, 1)];
    id<ORIntVar> objective = [ORFactory intVar: m domain: RANGE(m, 0, (ORInt)instance.sets.count)];
    
    [m minimize: objective];
    [m add: [objective eq: Sum(m, i, setRange, [s at: i])]];
    for(ORInt n = [universe low]; n <= [universe up]; n++) {
        id<ORExpr> expr = [ORFactory sum: m over: setRange
                                suchThat: ^bool(ORInt i) { return [[instance.sets at: i] member: n]; }
                                      of: ^id<ORExpr>(ORInt i) { return [s at: i]; }];
        [m add: expr];
    }
    
    for (ORInt i = [setRange low]; i <= [setRange up]; i++) {
        NSLog(@"s%i, %@", i, [instance.sets at: i]);
    }
    
    id<ORRunnable> r = [ORFactory MIPRunnable: m];
    [r start];
    
    return 0;
}
