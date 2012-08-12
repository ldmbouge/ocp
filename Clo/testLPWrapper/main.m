/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2012 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import "lpsolver/lpsolver.h"

static int nbRows = 7;
static int nbColumns = 12;

int b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
float c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
float coef[7][12] = {
    { 19,   1,  10,  1,   1,  14, 152, 11,  1,   1, 1, 1},
    {  0,   4,  53,  0,   0,  80,   0,  4,  5,   0, 0, 0},
    {  4, 660,   3,  0,  30,   0,   3,  0,  4,  90, 0, 0},
    {  7,   0,  18,  6, 770, 330,   7,  0,  0,   6, 0, 0},
    {  0,  20,   0,  4,  52,   3,   0,  0,  0,   5, 4, 0},
    {  0,   0,  40, 70,   4,  63,   0,  0, 60,   0, 4, 0},
    {  0,  32,   0,  0,   0,   5,   0,  3,  0, 660, 0, 9}};

int main(int argc, const char * argv[]) 
{
    id pool = [NSAutoreleasePool new];
    
    @try {
        
        id<LPSolver> lp = [LPFactory solver];
        [lp print];
        
        id<LPVariable> x[nbColumns];
        for(ORInt i = 0; i < nbColumns; i++) 
            x[i] = [lp createVariable];
        
        id<LPLinearTerm> obj = [lp createLinearTerm];
        for(ORInt i = 0; i < nbColumns; i++)
            [obj add: c[i] times: x[i]];
        id<LPObjective> o = [lp postObjective: [lp createMaximize: obj]];
        
        id<LPConstraint> c[nbRows];
        for(ORInt i = 0; i < nbRows; i++) {
            id<LPLinearTerm> t = [lp createLinearTerm];
            for(ORInt j = 0; j < nbColumns; j++)
                [t add: coef[i][j] times: x[j]];
            c[i] = [lp postConstraint: [lp createLEQ: t rhs: b[i]]];
        }
        
        [lp solve];
        [lp print];
        
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[o value]);
        for(ORInt i = 0; i < nbColumns; i++) 
            printf("Value of %d is %f \n",i,[x[i] value]);
        for(ORInt i = 0; i < nbRows; i++) 
            printf("Dual of %d is %f \n",i,[c[i] dual]);
        
        [lp release];
        
        
    }
    @catch (NSException* ee) {
        printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
    }
    [pool release];
    return 0;
}

/*
int mainb(int argc, const char * argv[]) 
{
    int       ind[3];
    LPVariable* av[3];
    LPConstraint* cstr[2];
    double    val[3];
    printf("Hello \n");
    
    id pool = [NSAutoreleasePool new];
    
    @try {
        
        LPSolver* lp = [LPSolver create];
        [lp print];
        
        LPVariable* var[3];
        for(ORInt i = 0; i < 3; i++) {
            var[i] = [lp createVariable: 0 up: 1];
        }
        
        // First constraint: x + 2 y + 3 z <= 4 
        
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 2; val[2] = 3;
        LPLinearTerm* tc1 = [lp createLinearTerm];
        [tc1 add:1 times: var[0]];
        [tc1 add:2 times: var[1]];
        [tc1 add:3 times: var[2]];
        
        cstr[0] = [lp postConstraint: [lp createLEQ: tc1 rhs: 4]];
        
        // objective 
        
        ind[0] = 0; ind[1] = 1; ind[2] = 2;
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 1; val[2] = 2;
        LPLinearTerm* ot = [lp createLinearTerm];
        [ot add: 1 times: var[0]];
        [ot add: 1 times: var[1]];
        [ot add: 2 times: var[2]];
        [lp postObjective: [lp createMaximize: ot]];
        
        // Second constraint: x + 2 y >= 3
        
        av[0] = var[0]; av[1] = var[1]; 
        val[0] = 1; val[1] = 2; 
        LPLinearTerm* tc2 = [lp createLinearTerm];
        [tc2 add:1 times: var[0]];
        [tc2 add:2 times: var[1]];
        cstr[1] = [lp postConstraint: [lp createGEQ: tc2 rhs: 3]];
        
        
        [lp solve];
        [lp print];
        
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
        
        [lp release];
        
        
    }
    @catch (NSException* ee) {
        printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
    }
    [pool release];
    return 0;
}

int main0(int argc, const char * argv[]) 
{
    int       ind[3];
    LPVariable* av[3];
    LPConstraint* cstr[2];
    double    val[3];
    printf("Hello \n");
    
    id pool = [NSAutoreleasePool new];
    
    @try {
        
        LPSolver* lp = [LPSolver create];
        [lp print];
        
        LPVariable* var[3];
        for(ORInt i = 0; i < 3; i++) {
            var[i] = [lp createVariable: 0 up: 1];
        }
        
        // First constraint: x + 2 y + 3 z <= 4 
        
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 2; val[2] = 3;
        
        cstr[0] = [lp postConstraint: [lp createLEQ: 3 var: av  coef: val rhs: 4]];
        
        // objective 
        
        ind[0] = 0; ind[1] = 1; ind[2] = 2;
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 1; val[2] = 2;
        
        [lp postObjective: [lp createMaximize: 3 var: av coef: val]];
        
        // Second constraint: x + 2 y >= 3 
        
        av[0] = var[0]; av[1] = var[1]; 
        val[0] = 1; val[1] = 2; 
        cstr[1] = [lp postConstraint: [lp createGEQ: 2 var: av coef: val  rhs: 3]];
    
        
        [lp close];
        [lp print];
        
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
   

//        [lp removeVariable: var[0]];
//        [lp print];
//        [lp solve];
        
//        printf("Status: %d \n",[lp status]);
//        printf("objective: %f \n",[lp objectiveValue]);
//        for(ORInt i = 0; i < 3; i++) 
//            printf("Value of %d is %f \n",i,[lp value: var[i]]);
        
        
        
        [lp removeConstraint: cstr[0]];
        [lp print];
        
        printf("Identifier of cstr[0]: %d \n",[cstr[0] idx]);
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);

        
        [lp postConstraint: cstr[0]];
        printf("Identifier of cstr[0]: %d \n",[cstr[0] idx]);
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
        [lp print];
        
        
        [lp removeConstraint: cstr[1]];
        printf("Identifier of cstr[0]: %d \n",[cstr[0] idx]);
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
        
        [lp print];
        
        [lp release];
        
        
    }
    @catch (NSException* ee) {
        printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
    }
    [pool release];
    return 0;
}

int main1(int argc, const char * argv[]) 
{
    int       ind[3];
    LPVariable* av[3];
    LPConstraint* cstr[2];
    double    val[3];
    printf("Hello \n");
    
    id pool = [NSAutoreleasePool new];
    
    @try {
        
        LPSolver* lp = [LPSolver create];
        [lp print];
        
        LPVariable* var[3];
        for(ORInt i = 0; i < 2; i++) {
            var[i] = [lp createVariable: 0 up: 1];
         }
        
        // First constraint: x + 2 y + 3 z <= 4 
        
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 2; val[2] = 3;
        
        cstr[0] = [lp createLEQ: 2 var: av  coef: val rhs: 4];
        [lp postConstraint: cstr[0]];
        
        /// Second constraint: x + 2 * y >= 3 
        
        av[0] = var[0]; av[1] = var[1]; 
        val[0] = 1; val[1] = 2; 
        [lp postConstraint: [lp createGEQ: 2 var: av coef: val  rhs: 3]];

        // objective 
        
        ind[0] = 0; ind[1] = 1; ind[2] = 2;
        av[0] = var[0]; av[1] = var[1]; av[2] = var[2];
        val[0] = 1; val[1] = 1; val[2] = 2;
        
        [lp postObjective: [lp createMaximize: 2 var: av coef: val]];
        
        [lp close];
        [lp solve];
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 2; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
        [lp print];
        
        double ccoef[1];
        ccoef[0] = 3.0;
        LPColumn* col = [lp createColumn: 0 up: 1];
        [col addObjCoef: 2];
        [col addConstraint: cstr[0] coef: 3.0];
        var[2] = [lp postColumn:col];
        
        printf("Status: %d \n",[lp status]);
        printf("objective: %f \n",[lp objectiveValue]);
        for(ORInt i = 0; i < 3; i++) 
            printf("Value of %d is %f \n",i,[lp value: var[i]]);
   
         
        [lp print];
        [lp release];
        
    }
    @catch (NSException* ee) {
        printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
    }
    [pool release];
    return 0;
}
*/



