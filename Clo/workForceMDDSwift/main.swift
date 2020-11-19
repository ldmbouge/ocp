/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck
 
 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.
 
 ***********************************************************************/

import ORProgram

typealias Job = (start:Int,end:Int,duration:Int)

func cleanRows(_ file:String)->String {
    var cleanFile = file
    cleanFile = cleanFile.replacingOccurrences(of: "\r", with: "\n")
    cleanFile = cleanFile.replacingOccurrences(of: "\n\n", with: "\n")
    return cleanFile
}

func readDataFromCSV(filepath:String)-> String! {
    do {
        var contents = try String(contentsOfFile: filepath, encoding: .utf8)
        contents = cleanRows(contents)
        return contents
    } catch {
        print("File Read Error for file \(filepath)")
        return nil
    }
}

func csv(filePath: String) -> [[Int]] {
    if let data = readDataFromCSV(filepath: filePath) {
        var result: [[Int]] = []
        let rows = data.components(separatedBy: "\n")
        for row in rows {
            var columns = row.components(separatedBy: ",")
            columns.removeFirst()
            let mc = columns.map { (s : String) -> Int in
                return Int(s) ?? 0
            }
            result.append(mc)
        }
        return result
    } else {
        return []
    }
}

func overlap(_ a : Job,_ b : Job) -> Bool {  // a = [L .. U] , b = [V .. W]
    return max(a.start,b.start) <= min(a.end,b.end)
}

func sweep(_ jobs : [Job]) -> Set<Set<Int>> {
    var cliques : Set<Set<Int>> = []
    typealias Evt = (time : Int,type : Bool,idx : Int)
    var pt : [Evt] = []
    for j in 0..<jobs.count {
        pt.append((jobs[j].start,true,j))
        pt.append((jobs[j].end,false,j))
    }
    pt.sort { (arg0, arg1) -> Bool in return arg0.time < arg1.time || (arg0.time == arg1.time && arg0.type && !arg1.type )}
    var clique : Set<Int> = []
    var added = false
    for p in pt {
        if p.type {
            clique.insert(p.idx)
        } else {
            if added {
                cliques.insert(clique)
            }
            clique.remove(p.idx)
        }
        added = p.type
    }
    return cliques
}

func all(_ t : ORTracker,_ over : Set<Int>,_ mf : (Int) -> ORIntVar) -> ORIntVarArray {
    let cvr = range(t,low:0,up:over.count-1)
    let cv = ORFactory.intVarArray(t, range: cvr)
    var cnt = 0
    for i in over {
        cv[cnt] = mf(i)
        cnt += 1
    }
    return cv
}

autoreleasepool {
    let arguments = CommandLine.arguments
    let numArguments = arguments.count
    
    let fileName = numArguments > 1 ? arguments[1] : "/Users/rebeccagentzel/Downloads/workforce100"
    let mode = numArguments > 2 ? Int(arguments[2]) : 1
    let relaxationSize = numArguments > 3 ? Int32(arguments[3]) : 1
    let usingFirstFail = numArguments > 4 ? Bool(arguments[4]) : false
    let splitAllLayersBeforeFiltering = numArguments > 5 ? Bool(arguments[5]) : true
    let maxSplitIter = numArguments > 6 ? Int32(arguments[6]) : 10
    let maxRebootDistance = numArguments > 7 ? Int32(arguments[7]) : 0
    let recommendationStyle = numArguments > 8 ? Int(arguments[8]) : 0
    let variableOverlap = numArguments > 9 ? Int32(arguments[9]) : 80
    let useStateExistence = numArguments > 10 ? Bool(arguments[10]) : true
    let nodePriorityMode = numArguments > 11 ? Int32(arguments[11]) : 0
    let candidatePriorityMode = numArguments > 12 ? Int32(arguments[12]) : 0
    let stateEquivalenceMode = numArguments > 13 ? Int32(arguments[13]) : 3
    let numNodesSplitAtATime = numArguments > 14 ? Int32(arguments[14]) : 1
    let numNodesDefinedAsPercent = numArguments > 15 ? Bool(arguments[15]) : false
    let splittingStyle = numArguments > 16 ? Int32(arguments[16]) : 0
    let printSolutions = numArguments > 17 ? Bool(arguments[17]) : true
    
    //mode = 0, classic, series of inequalities
    //mode = 1, classic, all-differents
    //mode = 2, MDD
    
    let jobsFile = fileName + "-jobs.csv"
    let compatFile = fileName + ".csv"
    
    var jbs = csv(filePath: jobsFile)
    jbs.removeFirst() // get rid of heading row
    let AJ = jbs.map { job in Job(job[0],job[1],job[2]) }
    let compat = csv(filePath: compatFile)
    let nbE = compat[0].count
    
    let cliques = sweep(AJ)
    
    let programStart    = ORRuntimeMonitor.cputime()
    
    let m  = ORFactory.createModel(),
        JR = range(m, 0...AJ.count-1),
        ER = range(m,0...nbE-1),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)

    let emp = ORFactory.intVarArray(m, range: JR, domain: ER)
    
    
    if mode! == 0 {
        for i in 0..<AJ.count {
            for j in i+1 ..< AJ.count {
                if (overlap(AJ[i],AJ[j])) {
                    m.add(emp[i]  != emp[j]);
                }
            }
        }
    } else if mode! == 1 {
        for c in cliques {
            notes.dc(m.add(ORFactory.alldifferent(all(m,c) { i in emp[i] })))
        }
    } else if mode! == 2 {
        for c in cliques {
            m.add(improvedAllDiffDualDirectionalMDDWithSetsAndClosures(all(m,c) { i in emp[i]}, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
        }
    }
    var objectiveUpperBound = 0
    for i in JR.low()...JR.up() {
        var rowMax = 0
        for j in ER.low()...ER.up() {
            if compat[Int(i)][Int(j)] > rowMax {
                rowMax = compat[Int(i)][Int(j)]
            }
        }
        objectiveUpperBound += rowMax
    }
    let objectiveDomain = range(m, 0...objectiveUpperBound)
    let objectiveVariable = ORFactory.intVar(m, domain: objectiveDomain)

    if mode! > 1 {
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
        
        m.maximizeVar(objectiveVariable)
        m.add(sumMDD(m: m, vars: emp, weightMatrix: compat, equal: objectiveVariable, constraintPriority: 0, nodePriorityMode: nodePriorityMode!, candidatePriorityMode: candidatePriorityMode!, stateEquivalenceMode: stateEquivalenceMode!))
    } else {
        var compatMatrix : [ORIntArray] = [];
        for i in JR.low()...JR.up() {
            compatMatrix.append(ORFactory.intArray(m, range: ER) { j in ORInt(compat[Int(i)][Int(j)]) })
        }
        
        m.maximize(sum(m, R: JR) { i in
            return compatMatrix[Int(i)][emp[i]]
        })
    }
    
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    //let cp = ORFactory.createCPProgram(m)
    
    var postEnd:ORLong = 0
    
    cp.search {
        Do(cp) {
          postEnd = ORRuntimeMonitor.cputime()
        }
        »
        whileDo(cp, {!cp.allBound(emp)}, {
            var bestVarIndex = Int32.min
            var bestDomSize = Int32.max
            for varIndex in JR.low()...JR.up() {
                let domSize = cp.domsize(emp[varIndex])
                if (domSize > 1 && domSize < bestDomSize) {
                    bestVarIndex = varIndex
                    bestDomSize = domSize
                }
            }
            return whileDo(cp,{!cp.bound(emp[ORInt(bestVarIndex)])}) {
                var largest = Int32.min
                var bestValue = Int32.min
                let minVal = emp[bestVarIndex].min()
                let maxVal = emp[bestVarIndex].max()
                for value in minVal...maxVal {
                    if (cp.member(value, in: emp[bestVarIndex]) == 0) { continue; }
                    if (largest < compat[Int(bestVarIndex)][Int(value)]) {
                        bestValue = value
                        largest = ORInt(compat[Int(bestVarIndex)][Int(value)])
                    }
                }
                return equal(cp, emp[bestVarIndex], bestValue) | diff(cp, emp[bestVarIndex], bestValue)
            }
        })
        »
          Do(cp) {
            let qs = (0..<AJ.count).map { i in cp.intValue(emp[ORInt(i)]) },
                f  = cp.objectiveValue()!
            if printSolutions! {
                print("sol is: \(qs) f = \(f)")
                print(cp.nbFailures())
            }
            nbSol.incr(cp)
        }
    }
    let programEnd     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Time to post: \(postEnd - programStart)\n")
    print("Quitting: \(programEnd - programStart)\n")
}
