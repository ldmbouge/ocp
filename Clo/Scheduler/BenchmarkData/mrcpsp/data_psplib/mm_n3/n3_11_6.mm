************************************************************************
file with basedata            : cn311_.bas
initial value random generator: 1045283570
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  138
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       11       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6  16
   3        3          2           5   7
   4        3          2          10  12
   5        3          3           8   9  11
   6        3          3           7   9  14
   7        3          3           8  11  15
   8        3          2          10  13
   9        3          2          15  17
  10        3          1          17
  11        3          1          13
  12        3          3          13  14  16
  13        3          1          17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     2       6    0    0    0    2
         2     2       0    7    0    0    2
         3     8       8    0    1    2    0
  3      1     2       0    2    7    0    9
         2     6       0    2    0    0    6
         3     8       0    1    6    0    0
  4      1     2       0    7    6    0    0
         2     2       0    3    7    6    7
         3     6       4    0    5    6    0
  5      1     6       0    7    0    0    5
         2     7       9    0    0    0    5
         3     9       0    5    3    3    0
  6      1     2       0    8    9    0    9
         2     8       6    0    9    0    0
         3     9       0    6    0    0    6
  7      1     5       6    0    6    8    3
         2     9       0   10    4    0    0
         3     9       0    8    0    7    2
  8      1     2       0    3    8    8    0
         2     4       3    0    0    0    9
         3    10       3    0    6    6    0
  9      1     2       0    8    0    9    0
         2     7       0    7    0    3    0
         3     8       0    5    8    0    6
 10      1     3      10    0   10    0    0
         2     9       0    5    0    0    4
         3    10       7    0   10    1    0
 11      1     3       0    6    4    0    0
         2     7       0    5    0    0    6
         3     8       0    3    2    6    5
 12      1     1       7    0    0    6    0
         2     7       0    2    0    6    0
         3     8       0    2   10    4    3
 13      1     5       7    0    0    6    0
         2     9       1    0    7    0    0
         3     9       0    1    0    2    0
 14      1     9       0    7    0    6    5
         2     9       0    6    6    0    0
         3    10       6    0    0    6    5
 15      1     6       5    0    0    0    5
         2     6       0    3    0    0    5
         3    10       0    3    0    8    0
 16      1     2       6    0    0    9   10
         2     7       0    5    0    8    6
         3     8       5    0    0    8    3
 17      1     3       9    0    6    6    9
         2     7       9    0    0    0    7
         3     8       8    0    0    0    5
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   19   24   49   48   50
************************************************************************
