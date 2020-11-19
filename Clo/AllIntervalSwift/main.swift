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
    let mode = numArguments > 2 ? Int(arguments[2]) : 2
    let relaxationSize = numArguments > 3 ? Int32(arguments[3]) : 8
    let usingFirstFail = numArguments > 4 ? Bool(arguments[4]) : false
    let splitAllLayersBeforeFiltering = numArguments > 5 ? Bool(arguments[5]) : true
    let maxSplitIter = numArguments > 6 ? Int32(arguments[6]) : 5 * relaxationSize!
    let maxRebootDistance = numArguments > 7 ? Int32(arguments[7]) : 10
    let recommendationStyle = numArguments > 8 ? Int(arguments[8]) : 0
    let variableOverlap = numArguments > 9 ? Int32(arguments[9]) : 0
    let useStateExistence = numArguments > 10 ? Bool(arguments[10]) : true
    let nodePriorityMode = numArguments > 11 ? Int32(arguments[11]) : 0
    let candidatePriorityMode = numArguments > 12 ? Int32(arguments[12]) : 0
    let stateEquivalenceMode = numArguments > 13 ? Int32(arguments[13]) : 0
    let numNodesSplitAtATime = numArguments > 14 ? Int32(arguments[14]) : 1
    let numNodesDefinedAsPercent = numArguments > 15 ? Bool(arguments[15]) : false
    let splittingStyle = numArguments > 16 ? Int32(arguments[16]) : 0
    let printSolutions = numArguments > 17 ? Bool(arguments[17]) : false
    
    let numVars = 11
    
    //mode = 0, Domain Encoding with equalAbsDiff
    //mode = 1, Domain Encoding with AbsDiff-Table Constraint
    //mode = 2, MDD Encoding
    //mode = 3, Both Domain Encoding w/ AbsDiff-Table and MDD Encoding
    
    let programStart    = ORRuntimeMonitor.cputime()
    
    let m  = ORFactory.createModel(),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0),
        varRange = range(m, 0...(2*numVars - 2)),
        varDomain = range(m, 0...(numVars-1))
    
    let vars = ORFactory.intVarArray(m, range: varRange, domain: varDomain)
    
    var xVarsIdx = [0]
    var yVarsIdx = [Int]()
    
    for i in 1...(2*numVars-2) {
      if ( i%2==0 ) {
        m.add(vars[i] != 0);
        yVarsIdx.append(i);
      }
      else {
        xVarsIdx.append(i);
      }
    }
    
    let xVars = all(m, range(m, 0...(xVarsIdx.count-1)), {i in vars[xVarsIdx[Int(i)]]})
    let yVars = all(m, range(m, 0...(yVarsIdx.count-1)), {i in vars[yVarsIdx[Int(i)]]})
    
    if mode == 0 {
        m.add(ORFactory.alldifferent(xVars))
        m.add(ORFactory.alldifferent(yVars))
        
        for i in 0..<(numVars-1) {
            m.add((xVars[i+1] - xVars[i] == yVars[i]) ||
                  (xVars[i] - xVars[i+1] == yVars[i]))
        }
    } else if mode == 2 {
        let tmpFirst = all(m, range(m, 0...2), {i in vars[i]})
        m.add(absDiffMDD(tmpFirst, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        for i in 1..<(numVars-1) {
            let tmpVarsIdx = [2*i-1, 2*i+1, 2*i+2]
            let tmpVars = all(m, range(m, 0...2), {i in vars[tmpVarsIdx[Int(i)]]})
            m.add(absDiffMDD(tmpVars, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        }
        m.add(improvedAllDiffDualDirectionalMDDWithSetsAndClosures(xVars, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        m.add(improvedAllDiffDualDirectionalMDDWithSetsAndClosures(yVars, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
    }
    
    if mode! == 2 || mode! == 3 {
        notes.ddWidth(relaxationSize!)
        notes.ddRelaxed(relaxationSize! > 0)
        notes.ddRecommendationStyle(MDDRecommendationStyle(rawValue: MDDRecommendationStyle.RawValue(recommendationStyle!)))
        notes.ddVariableOverlap(variableOverlap!)
        notes.ddSplitAllLayers(beforeFiltering: splitAllLayersBeforeFiltering!)
        notes.ddMaxSplitIter(maxSplitIter!)
        notes.ddMaxRebootDistance(maxRebootDistance!)
        notes.ddUseStateExistence(useStateExistence!)
        notes.ddNumNodesSplit(atATime: numNodesSplitAtATime!)
        notes.ddNumNodesDefined(asPercent: numNodesDefinedAsPercent!)
        notes.ddSplittingStyle(splittingStyle!)
    }
    
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    //let cp = ORFactory.createCPProgram(m)
    
    var postEnd:ORLong = 0
    if usingFirstFail! {
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            firstFail(cp, xVars)
                »
                Do(cp) {
                    if (printSolutions!) {
                        let qs = (0...(2*numVars-2)).map { i in cp.intValue(vars[ORInt(i)]) }
                        print("sol is: \(qs)")
                    }
                    nbSol.incr(cp)
                }
        }
    } else {
        var numSolns = 0
        cp.searchAll {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            labelArray(cp, xVars)
                »
                Do(cp) {
                    if (printSolutions!) {
                        let qs = (0...(2*numVars-2)).map { i in cp.intValue(vars[ORInt(i)]) }
                        print("sol is: \(qs)")
                    }
                    /*let xs = (0...(numVars-1)).map { i in cp.intValue(xVars[ORInt(i)]) }
                    print("sol is: \(xs)")
                    let ys = (0...(numVars-2)).map { i in cp.intValue(yVars[ORInt(i)]) }
                    print("diffSol is: \(ys)")
                    nbSol.incr(cp)*/
                    numSolns += 1
                }
        }
        print("Num solns: \(numSolns)\n")
    }
    let programEnd     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Time to post: \(postEnd - programStart)\n")
    print("Quitting: \(programEnd - programStart)\n")
}
