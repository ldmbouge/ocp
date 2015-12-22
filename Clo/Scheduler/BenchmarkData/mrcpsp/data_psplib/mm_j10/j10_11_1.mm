************************************************************************
file with basedata            : mm11_.bas
initial value random generator: 13497
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  84
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       20        4       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           6
   3        3          2           7   9
   4        3          2           5  10
   5        3          2           7   9
   6        3          3           7   9  10
   7        3          1           8
   8        3          1          11
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       0    9    0    8
         2     6      10    0    0    7
         3     7       7    0    5    0
  3      1     6       8    0    5    0
         2     6       0    1    8    0
         3     7       6    0    0    6
  4      1     4       3    0    0    9
         2     6       0    5    0    5
         3    10       3    0    2    0
  5      1     2       0    8    8    0
         2     4       3    0    0    3
         3     9       2    0    0    2
  6      1     2       7    0    9    0
         2     8       6    0    0    7
         3    10       3    0    6    0
  7      1     8       2    0    5    0
         2    10       0    1    2    0
         3    10       0    3    0    7
  8      1     4       0    7    0    5
         2     4       0    6    4    0
         3     7       0    4    0    8
  9      1     2       9    0    0   10
         2     3       7    0    0   10
         3     8       7    0    0    9
 10      1     3       0    6    0    4
         2     5       0    2    0    3
         3    10       4    0    0    2
 11      1     1       4    0    0    6
         2     1       6    0    0    2
         3     6       2    0    6    0
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   10   33   51
************************************************************************
