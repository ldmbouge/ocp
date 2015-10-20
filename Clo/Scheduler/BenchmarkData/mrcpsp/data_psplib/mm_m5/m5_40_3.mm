************************************************************************
file with basedata            : cm540_.bas
initial value random generator: 1903028577
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  145
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       13        1       13
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           5   6   8
   3        5          3           5  10  12
   4        5          2           5  17
   5        5          2          15  16
   6        5          1           7
   7        5          3           9  10  11
   8        5          2          11  14
   9        5          3          12  13  16
  10        5          2          14  16
  11        5          2          12  17
  12        5          1          15
  13        5          1          14
  14        5          2          15  17
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     2       8   10    7    4
         2     5       7    9    7    3
         3     6       6    8    6    3
         4     7       4    8    6    2
         5     9       3    7    5    2
  3      1     2       6    8    9    2
         2     3       3    5    8    2
         3     4       1    3    6    2
         4     4       3    3    5    1
         5     4       2    2    5    2
  4      1     2      10    7    9    7
         2     6       8    6    9    4
         3     6       7    7    9    5
         4     6       7    6    9    6
         5     9       6    4    8    4
  5      1     2       4   10    3    8
         2     2       3   10    4    8
         3     2       4    9    4    7
         4     3       3    7    2    6
         5     8       2    5    2    4
  6      1     1       9    3    6    6
         2     3       9    3    6    4
         3     4       8    2    5    4
         4     9       7    2    5    3
         5    10       7    1    5    3
  7      1     1      10    9    6    4
         2     6       9    9    6    3
         3     7       8    8    6    3
         4     8       7    8    6    3
         5    10       5    8    6    2
  8      1     3       4    8    9    2
         2     4       3    7    8    2
         3     7       3    6    7    1
         4     8       3    3    6    1
         5    10       2    1    6    1
  9      1     2       4    6    8   10
         2     2       3    7    8    9
         3     3       3    5    8    9
         4     5       2    5    7    7
         5    10       1    2    7    7
 10      1     1       4    5   10    6
         2     1       4    4   10    7
         3     7       3    2    8    6
         4     7       4    2    7    6
         5     9       3    1    7    1
 11      1     1       8    7    8    3
         2     5       6    5    7    3
         3     5       6    6    6    3
         4     9       5    4    2    3
         5     9       6    3    2    3
 12      1     1       1    5    9    4
         2     4       1    5    8    4
         3     7       1    5    8    3
         4     9       1    5    7    2
         5    10       1    5    6    2
 13      1     3       8    9    8    7
         2     3       8    9    9    6
         3     4       7    9    8    4
         4     6       7    8    7    4
         5     8       6    8    5    2
 14      1     2       6    8    6    4
         2     4       4    5    5    4
         3     7       3    5    3    3
         4    10       2    1    2    3
         5    10       3    2    2    2
 15      1     2       4    6   10    7
         2     3       4    4    9    7
         3     4       3    4    6    7
         4     8       3    4    5    6
         5     9       3    2    4    5
 16      1     2       9    4    6    3
         2     4       8    4    4    2
         3     6       8    3    4    2
         4     9       7    3    3    2
         5    10       7    3    2    1
 17      1     1       8    9   10    7
         2     2       8    9    6    7
         3     4       6    8    5    6
         4     8       5    7    4    6
         5    10       3    6    2    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   24   27   87   56
************************************************************************
