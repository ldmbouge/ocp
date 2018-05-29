************************************************************************
file with basedata            : cm519_.bas
initial value random generator: 1105394261
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  143
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       11       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          1           6
   3        5          3           5   9  13
   4        5          3           7   8  11
   5        5          3           7   8  16
   6        5          2          11  12
   7        5          2          12  14
   8        5          1          10
   9        5          2          11  17
  10        5          3          12  14  15
  11        5          2          15  16
  12        5          1          17
  13        5          3          14  15  16
  14        5          1          17
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       5    0    9    0
         2     6       0    6    0    5
         3     6       4    0    7    0
         4     8       4    0    0    5
         5    10       0    5    6    0
  3      1     5       0    6    6    0
         2     6       0    5    0    7
         3     6       0    1    0    9
         4     8       2    0    0    5
         5     9       2    0    5    0
  4      1     3       5    0    6    0
         2     5       3    0    5    0
         3     8       0    9    5    0
         4     9       0    7    0    9
         5     9       2    0    0    7
  5      1     1       4    0    9    0
         2     5       3    0    0    2
         3     7       3    0    5    0
         4     7       2    0    6    0
         5    10       2    0    5    0
  6      1     1       0    9    9    0
         2     9       8    0    7    0
         3     9       0    8    0    7
         4     9      10    0    0    7
         5    10       0    8    0    5
  7      1     2       0    8    4    0
         2     4       0    6    4    0
         3     5       0    6    0    4
         4     6       4    0    3    0
         5    10       0    5    2    0
  8      1     5       8    0    0    9
         2     5       0    8    0    9
         3     5       0    9    7    0
         4     6       9    0    0    6
         5     9       0    3    6    0
  9      1     3       0   10    4    0
         2     4       9    0    0    5
         3     5       9    0    0    4
         4     6       0   10    0    4
         5     6       9    0    3    0
 10      1     1       4    0    9    0
         2     1       0    8    0    7
         3     6       0    8    0    5
         4     7       3    0    9    0
         5     8       2    0    0    1
 11      1     3       0    8    0    8
         2     3       0    8    5    0
         3     4       7    0    0    7
         4     7       0    7    5    0
         5     7       6    0    5    0
 12      1     1       6    0    0    4
         2     3       6    0   10    0
         3     5       5    0    6    0
         4     7       0    8    0    2
         5     9       0    6    0    2
 13      1     2       0    9    7    0
         2     5       1    0    7    0
         3     7       1    0    6    0
         4     8       0    9    6    0
         5    10       0    8    6    0
 14      1     8       7    0    3    0
         2     8       5    0    4    0
         3     9       0    9    0    8
         4     9       5    0    3    0
         5    10       4    0    0    8
 15      1     2       0    7    0    8
         2     5       0    6    7    0
         3     6       0    6    5    0
         4    10       5    0    5    0
         5    10       0    5    0    3
 16      1     2       8    0    0    6
         2     5       6    0    0    4
         3     7       0    8    0    4
         4     8       0    6    0    1
         5     8       5    0    0    3
 17      1     1       0    4    4    0
         2     2       1    0    0    8
         3     2       1    0    3    0
         4     5       0    3    0    6
         5     8       0    1    3    0
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   25   28   77   75
************************************************************************
