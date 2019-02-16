/************************************************************************
 Mozilla Public License
 
 Copyright (c) 2015 NICTA, Laurent Michel and Pascal Van Hentenryck

 This Source Code Form is subject to the terms of the Mozilla Public
 License, v. 2.0. If a copy of the MPL was not distributed with this
 file, You can obtain one at http://mozilla.org/MPL/2.0/.

 ***********************************************************************/


#import <Foundation/Foundation.h>
#import <objlp/LPSolver.h>

static int nbRows = 7;
static int nbColumns = 12;

int b[7] = { 18209, 7692, 1333, 924, 26638, 61188, 13360 };
double c[12] = { 96, 76, 56, 11, 86, 10, 66, 86, 83, 12, 9, 81 };
double coef[7][12] = {
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
        
       printf("This works my friend\n");
    }
    @catch (NSException* ee) {
        printf("ExecutionError: %s \n",[[ee reason] cStringUsingEncoding: NSASCIIStringEncoding]);
    }
    [pool release];
    return 0;
}

