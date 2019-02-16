************************************************************************
file with basedata            : cm539_.bas
initial value random generator: 846181113
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  140
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       12        8       12
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           5   6   7
   3        5          2          12  17
   4        5          2          11  12
   5        5          2           8   9
   6        5          3           8   9  12
   7        5          2           9  14
   8        5          3          10  11  14
   9        5          2          10  16
  10        5          2          15  17
  11        5          2          16  17
  12        5          2          13  15
  13        5          1          16
  14        5          1          15
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       7    5    9    4
         2     7       6    5    9    3
         3     8       5    4    6    3
         4     8       4    4    8    3
         5     9       2    4    5    1
  3      1     2      10    3    7    7
         2     8       9    3    7    7
         3     9       6    3    7    7
         4     9       7    3    7    6
         5    10       5    2    7    6
  4      1     2       7    7    4    7
         2     2       8    6    4    7
         3     6       6    5    3    6
         4     7       5    4    3    4
         5    10       3    4    3    4
  5      1     4       7    9    7    5
         2     5       7    7    7    4
         3     7       6    6    6    4
         4     7       7    5    6    4
         5     8       6    5    6    3
  6      1     1       7    6    6    9
         2     3       7    5    6    9
         3     4       7    5    6    7
         4     6       7    4    6    7
         5     8       7    4    6    6
  7      1     1       7    9   10   10
         2     2       6    8    9    9
         3     8       6    6    9    8
         4     9       5    4    8    8
         5    10       4    2    8    8
  8      1     4       8    7    7    4
         2     8       7    7    7    2
         3     8       8    6    7    2
         4     8       8    7    6    4
         5    10       7    6    6    2
  9      1     1       4    3    5    7
         2     3       4    2    4    6
         3     7       4    2    4    4
         4    10       3    1    3    3
         5    10       2    2    2    4
 10      1     1       8    5    6    8
         2     2       6    4    6    7
         3     4       5    4    5    4
         4     7       4    4    3    1
         5     7       5    3    2    3
 11      1     1       3    7    6    6
         2     3       3    5    5    4
         3     5       2    4    4    3
         4     5       2    4    2    4
         5     7       2    4    2    3
 12      1     4       5    9    9   10
         2     6       5    9    6    9
         3     8       4    8    5    7
         4     9       2    7    4    7
         5    10       1    7    3    5
 13      1     1       8    6    9    6
         2     1       8    6    8    7
         3     2       8    5    8    5
         4     3       7    5    6    5
         5     7       7    4    6    2
 14      1     1       8    6    8   10
         2     1       6    7    8    9
         3     2       6    6    7    9
         4     5       3    6    7    7
         5     7       1    4    6    7
 15      1     1       8    9    7    8
         2     3       8    7    6    7
         3     5       8    7    5    6
         4     8       8    5    5    6
         5    10       8    5    4    5
 16      1     2       8    2   10    8
         2     2       9    2   10    7
         3     3       7    2    8    6
         4     7       6    2    7    4
         5    10       3    1    4    3
 17      1     1       4    3    8    6
         2     2       4    2    6    6
         3     2       4    3    6    5
         4     5       3    2    5    5
         5     7       3    1    4    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   31   27   85   77
************************************************************************
