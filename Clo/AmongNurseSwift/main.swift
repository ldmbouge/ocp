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
    let mode = numArguments > 2 ? Int(arguments[2]) : 1
    let relaxationSize = numArguments > 3 ? Int32(arguments[3]) : 64
    let usingFirstFail = numArguments > 6 ? Bool(arguments[6]) : false
    let recommendationStyle = numArguments > 9 ? Int(arguments[9]) : 0
    let variableOverlap = numArguments > 10 ? Int32(arguments[10]) : 0
    
    //mode = 0, classic constraint
    //mode = 1, among MDD
    //mode = 2, sequence MDD
    let constraintClass = 1,
        singleCumulative = false
    
    let programStart    = ORRuntimeMonitor.cputime()
    
    let m  = ORFactory.createModel(),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0),
        planningHorizon = 40,
        binaryDomain = range(m, 0...1),
        dayRange = range(m, 1...planningHorizon),
        setOfOne : Set = [1],
        intSetOfOne = ORFactory.intSet(m, set: setOfOne)
    
    let vars = ORFactory.intVarArray(m, range: dayRange, domain: binaryDomain)
    
    let maxWorkDays     = [6,  6,  7]
    let maxWorkDayRange = [8,  9,  9]
    let minWorkDays     = [22, 20, 22]
    let minWorkDayRange = [30, 30, 30]
    
    let minWorkDaysPerWeek = 4
    let maxWorkDaysPerWeek = 5
    
    if mode! > 0 {
        
        notes.ddWidth(relaxationSize!)
        notes.ddRelaxed(relaxationSize! > 0)
        notes.ddRecommendationStyle(MDDRecommendationStyle(rawValue: MDDRecommendationStyle.RawValue(recommendationStyle!)))
        notes.ddVariableOverlap(variableOverlap!)
    }
    
    if (mode == 0) {
        let cumulRange = range(m, 0...planningHorizon)
        if (singleCumulative) {
            let cumulative = ORFactory.intVarArray(m, range: cumulRange, domain:cumulRange)
            m.add(cumulative[0] == 0)
            for i in 1...planningHorizon {
                m.add(cumulative[i] == cumulative[i-1] + vars[i])
            }
            //Max Work
            for i in 0...planningHorizon-maxWorkDayRange[constraintClass] {
                m.add(cumulative[i + maxWorkDayRange[constraintClass]] ≤ cumulative[i] + maxWorkDays[constraintClass])
                m.add(cumulative[i + maxWorkDayRange[constraintClass]] ≥ cumulative[i] + 0)
            }
            //Min Work
            for i in 0...planningHorizon-minWorkDayRange[constraintClass] {
                m.add(cumulative[i + minWorkDayRange[constraintClass]] ≤ cumulative[i] + minWorkDayRange[constraintClass])
                m.add(cumulative[i + minWorkDayRange[constraintClass]] ≥ cumulative[i] + minWorkDays[constraintClass])
            }
            //Calendar Week
            for i in 0..<planningHorizon/7 {
                let firstDayOfWeek = i*7 + 1
                let lastDayOfWeek = firstDayOfWeek + 6
                if (lastDayOfWeek <= planningHorizon) {
                    m.add(cumulative[lastDayOfWeek] ≥ cumulative[firstDayOfWeek-1] + minWorkDaysPerWeek)
                    m.add(cumulative[lastDayOfWeek] ≤ cumulative[firstDayOfWeek-1] + maxWorkDaysPerWeek)
                }
            }
        } else {
            let cumulativeForMaxWork = ORFactory.intVarArray(m, range: cumulRange, domain:cumulRange)
            let cumulativeForMinWork = ORFactory.intVarArray(m, range: cumulRange, domain:cumulRange)
            m.add(cumulativeForMaxWork[0] == 0)
            m.add(cumulativeForMinWork[0] == 0)
            for i in 1...planningHorizon {
                m.add(cumulativeForMaxWork[i] == cumulativeForMaxWork[i-1] + vars[i])
                m.add(cumulativeForMinWork[i] == cumulativeForMinWork[i-1] + vars[i])
            }
            //Max Work
            for i in 0...planningHorizon-maxWorkDayRange[constraintClass] {
                m.add(cumulativeForMaxWork[i + maxWorkDayRange[constraintClass]] ≤ cumulativeForMaxWork[i] + maxWorkDays[constraintClass])
                m.add(cumulativeForMaxWork[i + maxWorkDayRange[constraintClass]] ≥ cumulativeForMaxWork[i] + 0)
            }
            //Min Work
            for i in 0...planningHorizon-minWorkDayRange[constraintClass] {
                m.add(cumulativeForMinWork[i + minWorkDayRange[constraintClass]] ≤ cumulativeForMinWork[i] + minWorkDayRange[constraintClass])
                m.add(cumulativeForMinWork[i + minWorkDayRange[constraintClass]] ≥ cumulativeForMinWork[i] + minWorkDays[constraintClass])
            }
            //Calendar Week
            for i in 0..<planningHorizon/7 {
                let firstDayOfWeek = i*7 + 1
                let lastDayOfWeek = firstDayOfWeek + 6
                if (lastDayOfWeek <= planningHorizon) {
                    m.add(cumulativeForMinWork[lastDayOfWeek] ≥ cumulativeForMinWork[firstDayOfWeek-1] + minWorkDaysPerWeek)
                    m.add(cumulativeForMaxWork[lastDayOfWeek] ≤ cumulativeForMaxWork[firstDayOfWeek-1] + maxWorkDaysPerWeek)
                }
            }
        }
    } else if (mode == 1) {
        //Max Work
        let maxWorkRange = range(m, 0...maxWorkDayRange[constraintClass]-1)
        for i in 1...planningHorizon-maxWorkDayRange[constraintClass]+1 {
            m.add(amongMDDClosures(m: m, x: all(m, maxWorkRange, {j in vars[i + Int(j)]}), lb: 0, ub: maxWorkDays[constraintClass], values: intSetOfOne))
        }
        //Min Work
        let minWorkRange = range(m, 0...minWorkDayRange[constraintClass]-1)
        for i in 1...planningHorizon-minWorkDayRange[constraintClass]+1 {
            m.add(amongMDDClosures(m: m, x: all(m, minWorkRange, {j in vars[i + Int(j)]}), lb: minWorkDays[constraintClass], ub: minWorkDayRange[constraintClass], values: intSetOfOne))
        }
        //Calendar Week
        let weekRange = range(m, 0...6)
        for i in 0..<planningHorizon/7 {
            let firstDayOfWeek = i*7 + 1
            let lastDayOfWeek = firstDayOfWeek + 6
            if (lastDayOfWeek <= planningHorizon) {
                m.add(amongMDDClosures(m: m, x: all(m, weekRange, {j in vars[firstDayOfWeek + Int(j)]}), lb: minWorkDaysPerWeek, ub: maxWorkDaysPerWeek, values: intSetOfOne))
            }
        }
    } else if (mode == 2) {
        //Max Work
        m.add(seqMDDClosuresWithBitSequence(vars, len: maxWorkDayRange[constraintClass], lb: 0, ub: maxWorkDays[constraintClass], values: setOfOne))
        //Min Work
        m.add(seqMDDClosuresWithBitSequence(vars, len: minWorkDayRange[constraintClass], lb: minWorkDays[constraintClass], ub: minWorkDayRange[constraintClass], values: setOfOne))
        //Calendar Week
        let weekRange = range(m, 0...6)
        for i in 0..<planningHorizon/7 {
            let firstDayOfWeek = i*7 + 1
            let lastDayOfWeek = firstDayOfWeek + 6
            if (lastDayOfWeek <= planningHorizon) {
                m.add(amongMDDClosures(m: m, x: all(m, weekRange, {j in vars[firstDayOfWeek + Int(j)]}), lb: minWorkDaysPerWeek, ub: maxWorkDaysPerWeek, values: intSetOfOne))
            }
        }
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
            firstFail(cp, vars)
                »
                Do(cp) {
                    let qs = (1...planningHorizon).map { i in cp.intValue(vars[ORInt(i)]) }
                    print("sol is: \(qs)")
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
            labelArray(cp, vars)
                »
                Do(cp) {
                    //let qs = (1...planningHorizon).map { i in cp.intValue(vars[ORInt(i)]) }
                    //print("sol is: \(qs)")
                    //nbSol.incr(cp)
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
