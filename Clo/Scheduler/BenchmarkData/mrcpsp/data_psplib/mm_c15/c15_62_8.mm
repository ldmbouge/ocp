************************************************************************
file with basedata            : c1562_.bas
initial value random generator: 1323797224
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  122
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       16       15       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  13
   3        3          1          17
   4        3          2          11  13
   5        3          2           6  14
   6        3          2           8  10
   7        3          1           9
   8        3          1          11
   9        3          1          16
  10        3          2          15  16
  11        3          2          12  16
  12        3          2          15  17
  13        3          1          15
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     4       9    3    7    6
         2     7       8    3    3    5
         3    10       5    2    2    3
  3      1     5       7    8   10    9
         2     5      10    8    8    9
         3    10       7    8    2    8
  4      1     5       2    8    7    8
         2     6       1    4    6    7
         3     6       1    6    7    6
  5      1     1       1    6    6    6
         2     2       1    5    6    5
         3     5       1    4    6    4
  6      1     1       7    4    8    4
         2     7       6    3    8    2
         3     9       6    3    8    1
  7      1     1       6    7    7    8
         2     5       3    7    7    8
         3     8       1    6    7    7
  8      1     1       6    7    6    9
         2     5       1    6    6    7
         3     5       1    4    6    9
  9      1     4       8    7    9   10
         2     6       6    6    8    9
         3    10       4    5    7    8
 10      1     2       4    6    3   10
         2     4       4    5    2    9
         3    10       3    3    2    8
 11      1     1       2    9    2    9
         2     1       2    8    3    9
         3     7       2    2    2    9
 12      1     4       8    7    5    5
         2     9       7    7    5    3
         3    10       5    6    4    2
 13      1     1       7    8    3   10
         2     3       7    4    3    8
         3     4       7    4    2    4
 14      1     1       8    2    6    8
         2     3       6    1    5    6
         3     7       6    1    4    2
 15      1     4       6   10    8    3
         2     6       5    5    7    3
         3     7       1    5    7    1
 16      1     4       8    2    5    9
         2     9       4    1    4    8
         3    10       1    1    3    5
 17      1     1       6    5    5    6
         2     2       6    4    4    5
         3     4       5    2    4    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   19   19   98  120
************************************************************************
