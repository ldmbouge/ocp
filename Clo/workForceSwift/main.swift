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
    pt.sort { (arg0, arg1) -> Bool in return arg0.time < arg1.time }
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
    var jbs = csv(filePath: "/Users/ldm/Desktop/workforce9-jobs.csv")
    jbs.removeFirst() // get rid of heading row
    let AJ = jbs.map { job in Job(job[0],job[1],job[2]) }
    let nbE = AJ.count
    let compat = csv(filePath: "/Users/ldm/Desktop/workforce9.csv")
    
    let cliques = sweep(AJ)
    
    let m  = ORFactory.createModel(),
        JR = range(m, 0...AJ.count-1),
        ER = range(m,0...nbE-1),
        notes = ORFactory.annotation(),
        nbSol = ORFactory.mutable(m, value: 0)
    let t0    = ORRuntimeMonitor.cputime()

    let emp = ORFactory.intVarArray(m, range: JR, domain: ER)
    
    for i in 0..<AJ.count {
        for j in i+1 ..< AJ.count {
            if (overlap(AJ[i],AJ[j])) {
                m.add(emp[i]  != emp[j]);
            }
        }
    }
    for c in cliques {
        notes.dc(m.add(ORFactory.alldifferent(all(m,c) { i in emp[i] })))
    }
    m.minimize(sum(m, R: JR) { i in
        let t = ORFactory.intArray(m, range: ER) { j in ORInt(compat[Int(i)][Int(j)]) }
        return t[emp[i]]
    })
    let cp = ORFactory.createCPProgram(m, annotation: notes)
    cp.search {
        firstFail(cp, emp)
            »
            Do(cp) {
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
