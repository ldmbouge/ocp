************************************************************************
file with basedata            : cn141_.bas
initial value random generator: 1219035997
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19        4       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          10  15
   3        3          3           5   6   7
   4        3          2           8   9
   5        3          1           8
   6        3          3          11  12  16
   7        3          2          10  12
   8        3          3          12  14  16
   9        3          3          11  13  14
  10        3          2          13  16
  11        3          1          17
  12        3          2          13  15
  13        3          1          17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     3       0    7    6
         2     4       0    5    5
         3    10       3    0    5
  3      1     2       4    0    6
         2     3       4    0    4
         3    10       3    0    2
  4      1     2       0    3    7
         2     3       6    0    7
         3     6       0    1    5
  5      1     2       6    0    2
         2     2       0    3    2
         3     7       0    1    2
  6      1     8       7    0    3
         2    10       6    0    2
         3    10       0    5    1
  7      1     2       0    4    2
         2     4       7    0    1
         3     8       5    0    1
  8      1     3       7    0    3
         2     8       0    6    3
         3     8       2    0    3
  9      1     1       0    3    6
         2     4       0    2    5
         3     9       0    1    4
 10      1     3       0    3    5
         2     8       7    0    5
         3     8       0    3    4
 11      1     4      10    0    8
         2     4       0    8    6
         3     8       9    0    5
 12      1     3       6    0    4
         2     6       0    7    3
         3    10       4    0    3
 13      1     2       4    0    8
         2     5       1    0    8
         3     9       0    1    7
 14      1     1       7    0    9
         2     1       0    2    9
         3     3       0    2    4
 15      1     1       0    9    7
         2     4       0    5    6
         3     5       6    0    3
 16      1     6       0    4   10
         2     7       7    0    9
         3     8       0    3    8
 17      1     4       6    0    6
         2     5       0    4    6
         3    10       3    0    3
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   10    6   76
************************************************************************
