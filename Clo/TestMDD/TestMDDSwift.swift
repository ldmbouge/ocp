//
//  TestMDD.swift
//  Clo
//
//  Created by Rebecca Gentzel on 1/25/20.
//

import Foundation
import ORProgram
import XCTest

class TestMDDSwift : XCTestCase {
    
    var model : ORModel!
    var notes : ORAnnotationProtocol!
    var minDom : Int!
    var maxDom : Int!
    var domainRange : ORIntRange!
    var minVar : Int!
    var maxVar : Int!
    var variableRange : ORIntRange!
    var vars : ORIntVarArray!
    var amongConstraintInputs : [AmongInput]!
    
    override func setUp() {
        super.setUp()
        model = ORFactory.createModel()
        notes = ORFactory.annotation()
        //Setup code here.  Called before every test
    }
    override func tearDown() {
        //Teardown code here.  Called after every test
        model = nil
        notes = nil
        domainRange = nil
        variableRange = nil
        vars = nil
        super.tearDown()
    }
    
    func setVars(minVar : Int, maxVar : Int, minDom : Int, maxDom : Int) {
        self.minVar = minVar
        self.maxVar = maxVar
        self.minDom = minDom
        self.maxDom = maxDom
        variableRange = range(model, minVar...maxVar)
        domainRange = range(model, minDom...maxDom)
        vars = ORFactory.intVarArray(model, range: variableRange, domain: domainRange)
    }
    
    func testExactAllDiffMDD() {
        autoreleasepool {
            setVars(minVar: 5, maxVar: 9, minDom: 3, maxDom: 7)
            model.add(allDiffMDD(vars))
            notes.ddRelaxed(false)
            let cp = ORFactory.createCPMDDProgram(model, annotation: notes)
            cp.search {
                labelArray(cp, self.vars)
                    »
                    Do(cp) {
                        self.variableRange.enumerate( {(varIndex : ORInt) in
                            XCTAssertEqual(cp.intValue(self.vars[varIndex]), ORInt(self.minDom! + Int(varIndex) - self.minVar!))
                        })
                    }
            }
        }
    }
    func relaxedAllDiffMDD(width : ORInt) {
        autoreleasepool {
            setVars(minVar: 0, maxVar: 4, minDom: 1, maxDom: 5)
            model.add(allDiffMDD(vars))
            notes.ddWidth(width)
            notes.ddRelaxed(true)
            let cp = ORFactory.createCPMDDProgram(model, annotation: notes)
            cp.search {
                labelArray(cp, self.vars)
                    »
                    Do(cp) {
                        for first in self.minVar...(self.maxVar-1) {
                            for second in (first+1)...self.maxVar {
                                XCTAssertNotEqual(cp.intValue(self.vars[first]), cp.intValue(self.vars[second]))
                            }
                        }
                    }
            }
        }
    }
    func testRelaxedAllDiffMDDWidth1() { relaxedAllDiffMDD(width: 1) }
    func testRelaxedAllDiffMDDWidth2() { relaxedAllDiffMDD(width: 2) }
    func testRelaxedAllDiffMDDWidth4() { relaxedAllDiffMDD(width: 4) }
    func testRelaxedAllDiffMDDWidth8() { relaxedAllDiffMDD(width: 8) }
    func testRelaxedAllDiffMDDWidth20() { relaxedAllDiffMDD(width: 20) }
    func testRelaxedAllDiffMDDWidth50() { relaxedAllDiffMDD(width: 50) }
    func testRelaxedAllDiffMDDWidth100() { relaxedAllDiffMDD(width: 100) }
    
    struct AmongInput {
        var lb : Int,
            ub : Int,
        values : ORIntSet
    }
    func amongInput(model : ORModel, lb : Int, ub : Int, values : Set<AnyHashable>) -> AmongInput {
        return AmongInput(lb: lb, ub: ub, values: ORFactory.intSet(model, set: values))
    }
    
    func testAmongMDD(relaxed : Bool, width : ORInt) {
        autoreleasepool {
            for amongConstraint in amongConstraintInputs {
                model.add(amongMDD(m: model, x: vars, lb: amongConstraint.lb, ub: amongConstraint.ub, values: amongConstraint.values))
            }
            notes.ddRelaxed(relaxed)
            notes.ddWidth(width)
            let cp = ORFactory.createCPMDDProgram(model, annotation: notes)
            cp.search {
                labelArray(cp, self.vars)
                    »
                    Do(cp) {
                        var valueCounts : [Int] = Array(repeating: 0, count: (self.maxDom-self.minDom+1))
                        for variableIndex in self.minVar...self.maxVar {
                            let valueIndex = Int(cp.intValue(self.vars[variableIndex])) - self.minDom
                            valueCounts[valueIndex] += 1
                        }
                        for amongConstraint in self.amongConstraintInputs {
                            var count = 0
                            amongConstraint.values.enumerate( {(value : ORInt) in
                                count += valueCounts[Int(value) - self.minDom]
                            } )
                            XCTAssertGreaterThanOrEqual(count, amongConstraint.lb)
                            XCTAssertLessThanOrEqual(count, amongConstraint.ub)
                        }
                    }
            }
        }
    }
    func setDefaultAmongMDD() {
        setVars(minVar: 1, maxVar: 10, minDom: 1, maxDom: 5)
        amongConstraintInputs = [
            amongInput(model: model, lb: 2, ub: 2, values: [2]),
            amongInput(model: model, lb: 2, ub: 2, values: [3]),
            amongInput(model: model, lb: 3, ub: 3, values: [4]),
            amongInput(model: model, lb: 3, ub: 3, values: [5])
        ]
    }
    func setLargeAmongMDD() {
        setVars(minVar: 1, maxVar: 200, minDom: 1, maxDom: 5)
        amongConstraintInputs = [
            amongInput(model: model, lb: 2, ub: 5, values: [2]),
            amongInput(model: model, lb: 2, ub: 5, values: [3]),
            amongInput(model: model, lb: 3, ub: 5, values: [4]),
            amongInput(model: model, lb: 3, ub: 5, values: [5])
        ]
    }
    
    func testExactAmongMDD() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: false, width: 1)
    }
    func testRelaxedAmongMDDWidth1() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 1)
    }
    func testRelaxedAmongMDDWidth2() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 2)
    }
    func testRelaxedAmongMDDWidth4() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 4)
    }
    func testRelaxedAmongMDDWidth8() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 8)
    }
    func testRelaxedAmongMDDWidth20() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 20)
    }
    func testRelaxedAmongMDDWidth50() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 50)
    }
    func testRelaxedAmongMDDWidth100() {
        setDefaultAmongMDD()
        testAmongMDD(relaxed: true, width: 100)
    }
    func testLargeExactAmongMDD() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: false, width: 1)
    }
    func testLargeRelaxedAmongMDDWidth1() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 1)
    }
    func testLargeRelaxedAmongMDDWidth2() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 2)
    }
    func testLargeRelaxedAmongMDDWidth4() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 4)
    }
    func testLargeRelaxedAmongMDDWidth8() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 8)
    }
    func testLargeRelaxedAmongMDDWidth20() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 20)
    }
    func testLargeRelaxedAmongMDDWidth50() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 50)
    }
    func testLargeRelaxedAmongMDDWidth100() {
        setLargeAmongMDD()
        testAmongMDD(relaxed: true, width: 100)
    }
}
