//
//  main.m
//  testMIP
//
//  Created by Pascal Van Hentenryck on 2/18/13.
//
//

#import <Foundation/Foundation.h>
#import "gurobi_c.h"
#import "LPGurobi.h"
#import "LPSolverI.h"

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
   
   @try {
      
      LPSolverI* lp = [LPFactory solver];
      [lp print];
      
      LPVariableI* x[nbColumns];
      for(ORInt i = 0; i < nbColumns; i++)
         x[i] = [lp createVariable];
      
      LPLinearTermI* obj = [lp createLinearTerm];
      for(ORInt i = 0; i < nbColumns; i++)
         [obj add: c[i] times: x[i]];
      LPObjectiveI* o = [lp postObjective: [lp createMaximize: obj]];
      
      LPConstraintI* c[nbRows];
      for(ORInt i = 0; i < nbRows; i++) {
         LPLinearTermI* t = [lp createLinearTerm];
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
   return 0;
}













int printSolution(GRBmodel* model, int nCategories, int nFoods);

int maing(int argc, const char * argv[])
{
   LPGurobiSolver* gurobi = [[LPGurobiSolver alloc] initLPGurobiSolver];
   [gurobi print];
   return 0;
}

int main1(int argc, const char * argv[])
{

   @autoreleasepool {
      
      GRBenv   *env   = NULL;
      GRBmodel *model = NULL;
      int       error = 0;
      int       i, j;
      int      *cbeg, *cind, idx;
      double   *cval, *rhs;
      char     *sense;

      const int nCategories = 4;
      char *Categories[] =
      { "calories", "protein", "fat", "sodium" };
      double minNutrition[] = { 1800, 91, 0, 0 };
      double maxNutrition[] = { 2200, GRB_INFINITY, 65, 1779 };
      
      /* Set of foods */
      const int nFoods = 9;
      char* Foods[] =
      { "hamburger", "chicken", "hot dog", "fries",
         "macaroni", "pizza", "salad", "milk", "ice cream" };
      double cost[] =
      { 2.49, 2.89, 1.50, 1.89, 2.09, 1.99, 2.49, 0.89, 1.59 };
      
      /* Nutrition values for the foods */
      double nutritionValues[][4] = {
         { 410, 24, 26, 730 },
         { 420, 32, 10, 1190 },
         { 560, 20, 32, 1800 },
         { 380, 4, 19, 270 },
         { 320, 12, 10, 930 },
         { 320, 15, 12, 820 },
         { 320, 31, 12, 1230 },
         { 100, 8, 2.5, 125 },
         { 330, 8, 10, 180 }
      };
      
      /* Create environment */
      error = GRBloadenv(&env, "diet.log");
      if (error || env == NULL)
      {
         fprintf(stderr, "Error: could not create environment\n");
         exit(1);
      }
      
      /* Create initial model */
      error = GRBnewmodel(env, &model, "diet", nFoods + nCategories,
                          NULL, NULL, NULL, NULL, NULL);
      if (error) goto QUIT;
      
      /* Initialize decision variables for the foods to buy */
      for (j = 0; j < nFoods; ++j)
      {
         error = GRBsetdblattrelement(model, "Obj", j, cost[j]);
         if (error) goto QUIT;
         error = GRBsetstrattrelement(model, "VarName", j, Foods[j]);
         if (error) goto QUIT;
      }
      
      /* Initialize decision variables for the nutrition information,
       which we limit via bounds */
      for (j = 0; j < nCategories; ++j)
      {
         error = GRBsetdblattrelement(model, "LB", j + nFoods, minNutrition[j]);
         if (error) goto QUIT;
         error = GRBsetdblattrelement(model, "UB", j + nFoods, maxNutrition[j]);
         if (error) goto QUIT;
         error = GRBsetstrattrelement(model, "VarName", j + nFoods, Categories[j]);
         if (error) goto QUIT;
      }
      
      /* The objective is to minimize the costs */
      error = GRBsetintattr(model, "ModelSense", 1);
      if (error) goto QUIT;
      
      /* Nutrition constraints */
      cbeg = malloc(sizeof(int) * nCategories);
      if (!cbeg) goto QUIT;
      cind = malloc(sizeof(int) * nCategories * (nFoods + 1));
      if (!cind) goto QUIT;
      cval = malloc(sizeof(double) * nCategories * (nFoods + 1));
      if (!cval) goto QUIT;
      rhs = malloc(sizeof(double) * nCategories);
      if (!rhs) goto QUIT;
      sense = malloc(sizeof(char) * nCategories);
      if (!sense) goto QUIT;
      idx = 0;
      for (i = 0; i < nCategories; ++i)
      {
         cbeg[i] = idx;
         rhs[i] = 0.0;
         sense[i] = GRB_EQUAL;
         for (j = 0; j < nFoods; ++j)
         {
            cind[idx] = j;
            cval[idx++] = nutritionValues[j][i];
         }
         cind[idx] = nFoods + i;
         cval[idx++] = -1.0;
      }
      
      error = GRBaddconstrs(model, nCategories, idx, cbeg, cind, cval, sense,
                            rhs, Categories);
      if (error) goto QUIT;
      
      /* Solve */
      error = GRBoptimize(model);
      if (error) goto QUIT;
      error = printSolution(model, nCategories, nFoods);
      if (error) goto QUIT;
      
      printf("\nAdding constraint: at most 6 servings of dairy\n");
      cind[0] = 7;
      cval[0] = 1.0;
      cind[1] = 8;
      cval[1] = 1.0;
      error = GRBaddconstr(model, 2, cind, cval, GRB_LESS_EQUAL, 6.0,
                           "limit_dairy");
      if (error) goto QUIT;
      
      /* Solve */
      error = GRBoptimize(model);
      if (error) goto QUIT;
      error = printSolution(model, nCategories, nFoods);
      if (error) goto QUIT;
      
      
      
   QUIT:
      
      /* Error reporting */
      
      if (error)
      {
         printf("ERROR: %s\n", GRBgeterrormsg(env));
         exit(1);
      }
      
      /* Free data */
      
      free(cbeg);
      free(cind);
      free(cval);
      free(rhs);
      free(sense);
      
      /* Free model */
      
      GRBfreemodel(model);
      
      /* Free environment */
      
      GRBfreeenv(env);

       // insert code here...
       NSLog(@"Hello, World!");
       
   }
    return 0;
}

int printSolution(GRBmodel* model, int nCategories, int nFoods)
{
   int error, status, i, j;
   double obj, x;
   char* vname;
   
   error = GRBgetintattr(model, "Status", &status);
   if (error) return error;
   if (status == GRB_OPTIMAL)
   {
      error = GRBgetdblattr(model, "ObjVal", &obj);
      if (error) return error;
      printf("\nCost: %f\n\nBuy:\n", obj);
      for (j = 0; j < nFoods; ++j)
      {
         error = GRBgetdblattrelement(model, "X", j, &x);
         if (error) return error;
         if (x > 0.0001)
         {
            error = GRBgetstrattrelement(model, "VarName", j, &vname);
            if (error) return error;
            printf("%s %f\n", vname, x);
         }
      }
      printf("\nNutrition:\n");
      for (i = 0; i < nCategories; ++i)
      {
         error = GRBgetdblattrelement(model, "X", i + nFoods, &x);
         if (error) return error;
         error = GRBgetstrattrelement(model, "VarName", i + nFoods, &vname);
         if (error) return error;
         printf("%s %f\n", vname, x);
      }
   }
   else
   {
      printf("No solution\n");
   }
   
   return 0;
}

