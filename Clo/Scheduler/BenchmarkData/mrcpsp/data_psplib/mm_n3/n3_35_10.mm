************************************************************************
file with basedata            : cn335_.bas
initial value random generator: 1871948250
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  119
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        9       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5   7
   3        3          3           5   6   8
   4        3          2           7   8
   5        3          2          11  16
   6        3          3          11  12  14
   7        3          3           9  10  13
   8        3          2          12  14
   9        3          1          14
  10        3          3          15  16  17
  11        3          1          13
  12        3          1          13
  13        3          2          15  17
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     2       0    8    2    4    6
         2     8       9    0    2    3    5
         3     9       0    7    1    2    3
  3      1     5       0    8    9    7    2
         2     8       7    0    8    7    2
         3     9       0    6    8    6    1
  4      1     1       0    2    8    5    4
         2     3       3    0    8    3    4
         3    10       2    0    8    3    3
  5      1     1       0    3    4    9    6
         2     3       0    2    4    9    4
         3     6       0    1    3    8    1
  6      1     1       6    0    9   10    6
         2     1       0    3    9   10    5
         3     9       8    0    8    9    5
  7      1     1       0    7    5   10    9
         2     2       0    4    4   10    4
         3     2       0    3    2    9    6
  8      1     2       7    0    5    8    8
         2     4       0    4    5    8    6
         3     6       0    2    3    7    6
  9      1     1       0    9    3    8    9
         2     2       0    9    2    7    8
         3     5       0    7    1    6    8
 10      1     4       0    6    6    8    7
         2     6       0    6    5    8    7
         3     9       0    6    5    8    2
 11      1     4       0    8    7    3    7
         2     9       0    6    6    2    6
         3    10       3    0    2    2    6
 12      1     1       0    6    5   10    8
         2     1       1    0    7    4    8
         3     1       0    7    5   10    6
 13      1     1       0    6    9   10    7
         2     5       0    5    6    8    7
         3     7       2    0    3    7    2
 14      1     5       5    0    8    7   10
         2     8       4    0    2    5   10
         3     8       0    5    3    5   10
 15      1     1       0    8    7    7    3
         2    10       4    0    6    3    3
         3    10       0    6    7    3    1
 16      1    10       0   10    2    4    4
         2    10       0    8    2    3    6
         3    10       4    0    1    6    3
 17      1     2       4    0   10    7    5
         2     3       3    0    8    6    5
         3     8       0    4    7    2    3
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   14   19   74   93   74
************************************************************************
