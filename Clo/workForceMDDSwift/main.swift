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
    return max(a.start,b.start) < min(a.end,b.end)
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
    let jobsFile = "/Users/rebeccagentzel/Downloads/workforce100-jobs.csv"
    let compatFile = "/Users/rebeccagentzel/Downloads/workforce100.csv"
    let relaxationSize = Int32(4)
    //let jobsFile = CommandLine.arguments[1]
    //let compatFile = CommandLine.arguments[2]
    //let relaxationSize = Int32(CommandLine.arguments[3])
    
    var jbs = csv(filePath: jobsFile)
    jbs.removeFirst() // get rid of heading row
    let AJ = jbs.map { job in Job(job[0],job[1],job[2]) }
    let compat = csv(filePath: compatFile)
    let nbE = compat[0].count
    
    let cliques = sweep(AJ)
    
    let m  = ORFactory.createModel(),
        JR = range(m, 0...AJ.count-1),
        ER = range(m,0...nbE-1),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()
    
    var compatMatrix : [ORIntArray] = [];
    for i in JR.low()...JR.up() {
        compatMatrix.append(ORFactory.intArray(m, range: ER) { j in ORInt(compat[Int(i)][Int(j)]) })
    }
    let emp = ORFactory.intVarArray(m, range: JR, domain: ER)
    
    for i in 0..<AJ.count {
        for j in i+1 ..< AJ.count {
            if (overlap(AJ[i],AJ[j])) {
                //m.add(emp[i]  != emp[j]);
            }
        }
    }
    for c in cliques {
        print(c.sorted())
        m.add(allDiffMDDWithSetsAndClosures(all(m,c) { i in emp[i]}))
    }
    m.maximize(sum(m, R: JR) { i in
        return compatMatrix[Int(i)][emp[i]]
    })
    notes.ddWidth(1)
    notes.ddRelaxed(true)
    notes.ddEqualBuckets(true)
    notes.dd(withArcs: true)
    notes.dd(usingSlack: false)
    notes.ddVariableOverlap(80)
    let cp = ORFactory.createCPMDDProgram(m, annotation: notes)
    var end:ORLong = 0
    var afterPropagation:ORLong = 0
    
    /*let paths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
    let documentsDirectory = paths[0]
    let filePath = documentsDirectory + "/workforceMDDSearch2.txt"
    FileManager.default.createFile(atPath: filePath, contents: nil, attributes: nil)*/
    cp.search {
        Do(cp) {
          end = ORRuntimeMonitor.cputime()
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
                /*let output = String(bestVarIndex) + " assigned to " + String(bestValue) + "\n"
                let data = output.data(using: String.Encoding.utf8, allowLossyConversion: false)!
                let fileHandle = FileHandle(forWritingAtPath: filePath)!
                fileHandle.seekToEndOfFile()
                fileHandle.write(data)
                fileHandle.closeFile()*/
                return equal(cp, emp[bestVarIndex], bestValue) | diff(cp, emp[bestVarIndex], bestValue)
            }
        })
        »
          Do(cp) {
            afterPropagation = ORRuntimeMonitor.cputime()
            let qs = (0..<AJ.count).map { i in cp.intValue(emp[ORInt(i)]) },
                f  = cp.objectiveValue()!
            print("sol is: \(qs) f = \(f)")
            nbSol.incr(cp)
        }
    }
    let t1     = ORRuntimeMonitor.cputime()
    print("Solver status: \(cp)\n")
    print("Quitting: \(t1 - t0)\n")
}
