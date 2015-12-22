************************************************************************
file with basedata            : cm561_.bas
initial value random generator: 518650500
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  139
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        2       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          2          14  16
   3        5          3           6   8  13
   4        5          3           5   7   9
   5        5          3          10  13  17
   6        5          2           7   9
   7        5          3          10  11  12
   8        5          2          15  17
   9        5          3          10  11  17
  10        5          2          14  16
  11        5          1          15
  12        5          1          14
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
  2      1     1       9   10    8   10
         2     3       9    9    6    7
         3     6       9    7    4    6
         4     9       9    4    4    5
         5     9       9    6    2    3
  3      1     2       8    7    9   10
         2     2       8    8    9    9
         3     5       8    5    6    8
         4     7       8    3    6    7
         5     8       7    1    5    4
  4      1     3      10   10    3    5
         2     4       8    6    3    4
         3     4       9    7    2    4
         4     7       8    4    2    3
         5    10       6    2    1    3
  5      1     5       8    1    5    8
         2     5       9    1    5    7
         3     6       8    1    4    5
         4     8       6    1    4    4
         5    10       2    1    4    2
  6      1     4       3    8    9    6
         2     4       4    8    8    5
         3     5       2    7    8    4
         4     5       2    8    8    3
         5     8       1    3    6    2
  7      1     3       5    7    7    4
         2     3       5    8    6    5
         3     6       4    5    6    4
         4     6       4    6    5    3
         5     8       3    1    4    3
  8      1     4       9    4    9    8
         2     5       9    4    7    7
         3     6       8    3    6    4
         4     6       9    2    5    4
         5     6       9    2    4    5
  9      1     2       8    5    8   10
         2     8       4    3    7    8
         3     8       5    4    5    6
         4     8       7    3    4    6
         5    10       2    2    2    6
 10      1     6       7    8    9    5
         2     8       7    5    7    5
         3     8       6    6    9    4
         4     9       6    5    6    3
         5    10       6    4    5    3
 11      1     1       8    9    8    9
         2     5       8    8    8    9
         3     7       8    8    7    8
         4     7       8    7    7    9
         5     8       8    6    7    8
 12      1     1       8    3    5    5
         2     2       7    3    5    5
         3     2       8    3    4    5
         4     3       5    3    3    5
         5     8       5    2    2    5
 13      1     2      10    8    6    4
         2     2       9   10    6    4
         3     4       9    7    5    4
         4     6       8    6    5    3
         5     7       6    4    4    3
 14      1     2       6   10    7    8
         2     2       6    9    7    9
         3     3       5    7    7    6
         4     7       5    6    7    3
         5     8       4    6    6    2
 15      1     5       8    8    8    4
         2     5       7   10    6    3
         3     7       7    8    5    3
         4     7       5    8    6    3
         5     9       4    6    1    2
 16      1     2       9    8    8    2
         2     2       8    8    9    2
         3     4       7    7    8    2
         4     9       7    3    4    2
         5    10       5    3    2    2
 17      1     1       9    8    9    5
         2     2       8    6    9    4
         3     6       5    5    9    3
         4    10       5    2    8    2
         5    10       3    3    8    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   15   12  119  105
************************************************************************
