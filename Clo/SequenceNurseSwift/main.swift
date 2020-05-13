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
    
    //mode = 0, cumulative sums (classic)
    //mode = 1, sequence MDD
    //mode = 2, sequence MDD w/ bottom-up
    
    let programStart    = ORRuntimeMonitor.cputime()
    
    let m  = ORFactory.createModel(),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0),
        planningHorizon = 40,
        boolRange = range(m, 0...1),
        shiftRange = range(m, 0...3),   //0 = Off, 1 = Day, 2 = Evening, 3 = Night
        dayRange = range(m, 1...planningHorizon)
    
    let off : Set = [0],
        on : Set = [1,2,3],
        evening : Set = [2],
        night : Set = [3],
        eveningOrNight : Set = [2,3]
    
    let vars = ORFactory.intVarArray(m, range: dayRange, domain: shiftRange)
    
    let sequences = [[14, 4, 14, off],
                     [28, 20, 28, on],
                     [14, 1, 4, night],
                     [14, 4, 8, evening],
                     [2, 0, 1, night],
                     [7, 2, 4, eveningOrNight],
                     [7, 0, 6, on]]
    
    if mode! > 0 {
        if (!usingClosures!) {
            print("Must use closures")
        }
        
        notes.ddWidth(relaxationSize!)
        notes.ddRelaxed(relaxationSize! > 0)
        notes.ddEqualBuckets(equalBuckets!)
        notes.dd(withArcs: withArcs!)
        notes.dd(usingSlack: usingSlack!)
        notes.ddRecommendationStyle(MDDRecommendationStyle(rawValue: MDDRecommendationStyle.RawValue(recommendationStyle!)))
        notes.ddVariableOverlap(variableOverlap!)
    }
    
    if (mode == 0) {
        let cumulRange = range(m, 0...planningHorizon)
        for sequence in sequences {
            let range = sequence[0] as! Int
            let lower = sequence[1] as! Int
            let upper = sequence[2] as! Int
            let set = sequence[3] as! Set<Int>
            let cumulative = ORFactory.intVarArray(m, range: cumulRange, domain:cumulRange)
            m.add(cumulative[0] == 0)
            let isMember = ORFactory.intVarArray(m, range: dayRange, domain:boolRange)
            let memberValues = ORFactory.intSet(m, set: set)
            for i in 1...planningHorizon {
                m.add(isMember[i] == memberValues.contains(vars[i]))
                m.add(cumulative[i] == cumulative[i-1] + isMember[i])
            }
            for i in 0...planningHorizon-range {
                m.add(cumulative[i + range] ≤ cumulative[i] + upper)
                m.add(cumulative[i + range] ≥ cumulative[i] + lower)
            }
        }
    } else if (mode == 1) {
        for sequence in sequences {
            let range = sequence[0] as! Int
            let lower = sequence[1] as! Int
            let upper = sequence[2] as! Int
            let set = sequence[3] as! Set<Int>
            m.add(seqMDDClosuresWithBitSequence(vars, len: range, lb: lower, ub: upper, values: set))
        }
    } else if (mode == 2) {
        for sequence in sequences {
            let range = sequence[0] as! Int
            let lower = sequence[1] as! Int
            let upper = sequence[2] as! Int
            let set = sequence[3] as! Set<Int>
            m.add(seqDualDirectionalMDDClosuresWithBitSequence(vars, len: range, lb: lower, ub: upper, values: set))
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
        cp.search {
            Do(cp) {
                postEnd = ORRuntimeMonitor.cputime()
            }
            »
            labelArray(cp, vars)
                »
                Do(cp) {
                    let qs = (1...planningHorizon).map { i in cp.intValue(vars[ORInt(i)]) }
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
