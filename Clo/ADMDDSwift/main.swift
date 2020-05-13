/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

autoreleasepool {
    let arguments = CommandLine.arguments
    let numArguments = arguments.count
    
    //let fileName = numArguments > 1 ? arguments[1] : ""
    let mode = numArguments > 2 ? Int(arguments[2]) : 0
    let relaxationSize = numArguments > 3 ? Int32(arguments[3]) : 1
    let withArcs = numArguments > 4 ? Bool(arguments[4]) : true
    let usingClosures = numArguments > 5 ? Bool(arguments[5]) : true
    let usingFirstFail = numArguments > 6 ? Bool(arguments[6]) : false
    let equalBuckets = numArguments > 7 ? Bool(arguments[7]) : true
    let usingSlack = numArguments > 8 ? Bool(arguments[8]) : false
    let recommendationStyle = numArguments > 9 ? Int(arguments[9]) : 0
    let variableOverlap = numArguments > 10 ? Int32(arguments[10]) : 0
    
    //Mode = 0: Classic w/ ValueConsistency
    //Mode = 1: Classic w/ DomainConsistency
    //Mode = 2: AllDiff MDD
    //Mode = 3: AllDiff MDD w/ Domain Consistent Classic
    
    let programStart    = ORRuntimeMonitor.cputime()
    let m  = ORFactory.createModel(),
        minDom = 0,maxDom = 4,
        minVar = 0,maxVar = 14,
        domainRange = range(m, minDom...maxDom),
        varRange = range(m, minVar...maxVar),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let cliques = [[0,1,2,5,6],
                   [3,4,6,8,9],
                   [3,5,7],
                   [4,5,7],
                   [4,5,7,8],
                   [6,7,9,10],
                   [7,8,9,11],
                   [7,10,11,12],
                   [8,9,10,13]]
    
    let vars = ORFactory.intVarArray(m, range: varRange, domain: domainRange)
    
    if mode == 0 {
        for clique in cliques {
            let cliqueRange = range(m, 0...(clique.count-1))
            let alldiffConstraint = ORFactory.alldifferent(all(m, cliqueRange, {j in vars[clique[Int(j)]]}))
            m.add(alldiffConstraint)
            notes.vc(alldiffConstraint)
        }
    } else if mode == 1 || mode == 3 {
        for clique in cliques {
            let cliqueRange = range(m, 0...(clique.count-1))
            m.add(ORFactory.alldifferent(all(m, cliqueRange, {j in vars[clique[Int(j)]]})))
        }
    }
    if mode == 2 || mode == 3 {
        if (!usingClosures!) {
            print("Must use closures")
        }
        for clique in cliques {
            let cliqueRange = range(m, 0...(clique.count-1))
            m.add(allDiffDualDirectionalMDDWithSetsAndClosures(all(m, cliqueRange, {j in vars[clique[Int(j)]]})))
        }
        
        
        notes.ddWidth(relaxationSize!)
        notes.ddRelaxed(relaxationSize! > 0)
        notes.ddEqualBuckets(equalBuckets!)
        notes.dd(withArcs: withArcs!)
        notes.dd(usingSlack: usingSlack!)
        notes.ddRecommendationStyle(MDDRecommendationStyle(rawValue: MDDRecommendationStyle.RawValue(recommendationStyle!)))
        notes.ddVariableOverlap(variableOverlap!)
    }
    
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    //let cp = ORFactory.createCPProgram(m, annotation: notes)
    
    var postEnd:ORLong = 0
    if usingFirstFail! {
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            firstFail(cp, vars)
                »
                Do(cp) {
                    let qs = (minVar...maxVar).map { i in cp.intValue(vars[ORInt(i)]) }
                    print("sol is: \(qs)")
                    nbSol.incr(cp)
                }
        }
    } else {
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            labelArray(cp, vars)
                »
                Do(cp) {
                    let qs = (minVar...maxVar).map { i in cp.intValue(vars[ORInt(i)]) }
                    print("sol is: \(qs)")
                    nbSol.incr(cp)
                }
        }
    }
    let programEnd     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Time to post: \(postEnd - programStart)\n")
    print("Quitting: \(programEnd - programStart)\n")
}
