************************************************************************
file with basedata            : cm242_.bas
initial value random generator: 2070608910
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       28        9       28
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        2          3           5   6  11
   3        2          3           7   8  10
   4        2          1          15
   5        2          2           9  13
   6        2          3           9  12  14
   7        2          2           9  11
   8        2          2          11  12
   9        2          1          16
  10        2          3          13  16  17
  11        2          2          13  14
  12        2          2          15  17
  13        2          1          15
  14        2          2          16  17
  15        2          1          18
  16        2          1          18
  17        2          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       5    0    6   10
         2     5       0    5    7    9
  3      1     1       9    0    8    5
         2     7       0    7    6    5
  4      1     1       0    5   10    9
         2     9       5    0   10    6
  5      1     7       9    0    5    9
         2    10       0    2    5    6
  6      1     6       0    6    3    2
         2     6       7    0    4    1
  7      1     2       0    7    5    5
         2     5       7    0    4    3
  8      1     3       3    0    3    6
         2     9       3    0    2    1
  9      1     5       0    3    1    7
         2     9       8    0    1    7
 10      1     2       7    0   10    5
         2     2       0    1    6    5
 11      1     2       0    2    5    4
         2     8       7    0    5    2
 12      1     7       7    0    3    7
         2     9       6    0    1    5
 13      1     2       6    0    9    6
         2     7       6    0    9    5
 14      1     4       0   10   10    6
         2    10       0    7    6    2
 15      1     2       9    0    9    6
         2     2       0    9    9    7
 16      1     6       5    0    5    8
         2    10       5    0    4    8
 17      1    10       0    4    8    8
         2    10       5    0    7    9
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   17   12   93   92
************************************************************************
