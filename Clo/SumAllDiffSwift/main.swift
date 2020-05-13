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
    
    //Mode = 0: Classic Domain Encoding
    //Mode = 1: MDD w/ lb <= sum(vars * weights) <= ub
    //Mode = 2: MDD w/ sum(vars * weights) == z (where z = lb...ub)
    //Mode = 3: MDD w/ sum(weightMatrix[var]) == z (where z = lb...ub)
    
    let programStart    = ORRuntimeMonitor.cputime()
    let m  = ORFactory.createModel(),
        minDom = 0,maxDom = 5,
        minVar = 0,maxVar = 4,
        domainRange = range(m, minDom...maxDom),
        varRange = range(m, minVar...maxVar),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    //Lower, Upper, Weights
    let sumConstraints = [[18, 19, [1, 2, 3, 4, 5]],
                          [18, 19, [5, 4, 3, 2, 1]],
                          [50, 65, [7, 8 , 11, 15, 4]]]
    let allDiffConstraints = [[0,1,2,4]]
    
    let vars = ORFactory.intVarArray(m, range: varRange, domain: domainRange)
    
    if mode == 0 {
        for sumConstraint in sumConstraints {
            let lower = sumConstraint[0] as! Int
            let upper = sumConstraint[1] as! Int
            let weights = sumConstraint[2] as! [Int]
            let maxWeight = weights.max()!
            let weightsPerVarDomain = range(m, 0...maxWeight * maxDom)
            let totalWeightsDomain = range(m, 0...maxWeight * maxDom * (maxVar-minVar+1))
            let valuesPerVar = ORFactory.intVarArray(m, range: varRange, domain: weightsPerVarDomain)
            for varIndex in minVar...maxVar {
                m.add(valuesPerVar[varIndex] == vars[varIndex]*weights[varIndex])
            }
            let totalWeight = ORFactory.intVar(m, domain: totalWeightsDomain)
            m.add(totalWeight == sum(m, R: varRange, b: {j in valuesPerVar[j]}))
            m.add(totalWeight ≥ lower)
            m.add(totalWeight ≤ upper)
        }
    } else if mode == 1 {
        if (!usingClosures!) {
            print("Must use closures")
        }
        for sumConstraint in sumConstraints {
            let lower = sumConstraint[0] as! Int
            let upper = sumConstraint[1] as! Int
            let weights = sumConstraint[2] as! [Int]
            m.add(sumMDD(m: m, vars: vars, weights: weights, lb: Int32(lower), ub: Int32(upper)))
        }
    } else if mode == 2 {
        if (!usingClosures!) {
            print("Must use closures")
        }
        for sumConstraint in sumConstraints {
            let lower = sumConstraint[0] as! Int
            let upper = sumConstraint[1] as! Int
            let weights = sumConstraint[2] as! [Int]
            let sumValueDomain = range(m, lower...upper)
            let sumValue = ORFactory.intVar(m, domain: sumValueDomain)
            m.add(sumMDD(m: m, vars: vars, weights: weights, equal: sumValue))
        }
    } else if mode == 3 {
        if (!usingClosures!) {
            print("Must use closures")
        }
        for sumConstraint in sumConstraints {
            let lower = sumConstraint[0] as! Int
            let upper = sumConstraint[1] as! Int
            let weights = sumConstraint[2] as! [Int]
            let sumValueDomain = range(m, lower...upper)
            let sumValue = ORFactory.intVar(m, domain: sumValueDomain)
            
            var weightMatrix : [[Int]] = []
            for varIndex in minVar...maxVar {
                var weightArray : [Int] = []
                for domainVal in minDom...maxDom {
                    weightArray.append(domainVal * weights[varIndex])
                }
                weightMatrix.append(weightArray)
            }
            
            m.add(sumMDD(m: m, vars: vars, weightMatrix: weightMatrix, equal: sumValue))
        }
    }
    
    if mode == 0 {
        for allDiffConstraint in allDiffConstraints {
            let allDiffRange = range(m, 0...(allDiffConstraint.count-1))
            m.add(ORFactory.alldifferent(all(m, allDiffRange, {j in vars[allDiffConstraint[Int(j)]]})))
        }
    } else {
        for allDiffConstraint in allDiffConstraints {
            let allDiffRange = range(m, 0...(allDiffConstraint.count-1))
            m.add(allDiffDualDirectionalMDDWithSetsAndClosures(all(m, allDiffRange, {j in vars[allDiffConstraint[Int(j)]]})))
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
