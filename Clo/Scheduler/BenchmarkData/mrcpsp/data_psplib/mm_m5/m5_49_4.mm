************************************************************************
file with basedata            : cm549_.bas
initial value random generator: 666314204
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  134
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       12       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           5   6   8
   3        5          2           7  12
   4        5          3          15  16  17
   5        5          3           9  11  15
   6        5          2           7  13
   7        5          1          10
   8        5          3          10  13  15
   9        5          2          10  12
  10        5          2          14  17
  11        5          3          12  13  17
  12        5          1          14
  13        5          1          16
  14        5          1          16
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     5       5    0    8    5
         2     5       7    0    7    5
         3     5       0   10    7    5
         4    10       6    0    6    2
         5    10       0    8    6    2
  3      1     4       3    0    7    9
         2     7       0    4    7    9
         3     7       3    0    6    9
         4     8       2    0    6    8
         5     9       2    0    3    8
  4      1     2       7    0    9   10
         2     3       5    0    9    8
         3     4       1    0    6    8
         4     8       0    3    6    7
         5    10       0    3    4    6
  5      1     1       5    0    7    8
         2     4       0    6    7    8
         3     8       5    0    5    7
         4     9       0    6    4    7
         5    10       3    0    3    7
  6      1     1       5    0    4   10
         2     2       3    0    4    9
         3     2       0    7    4    9
         4     6       0    5    3    9
         5     7       5    0    3    7
  7      1     5       0    6    9    7
         2     6       7    0    8    7
         3     7       0    6    7    6
         4     9       7    0    4    4
         5     9       0    6    5    5
  8      1     2       0    9   10    7
         2     3       0    7    9    7
         3     5       8    0    9    4
         4     6       6    0    8    4
         5     6       0    7    8    3
  9      1     4       0    6    7    6
         2     5       8    0    7    5
         3     6       0    5    6    3
         4     8       0    4    6    3
         5     8       5    0    6    3
 10      1     1       8    0    8    8
         2     6       0    3    8    7
         3     8       3    0    7    6
         4     8       4    0    7    5
         5     8       0    3    8    5
 11      1     1       0    6    6    4
         2     3       0    4    5    4
         3     6       9    0    5    4
         4     7       5    0    5    4
         5     8       2    0    4    4
 12      1     4       2    0    9   10
         2     4       0    3    8   10
         3     6       0    3    8    9
         4     7       0    2    7    8
         5     8       2    0    6    6
 13      1     2       0    8    7    7
         2     5       7    0    6    7
         3     8       5    0    3    7
         4    10       0    4    1    6
         5    10       3    0    3    5
 14      1     1       7    0    6   10
         2     5       5    0    6    6
         3     5       6    0    5    7
         4     5       0   10    6    7
         5     8       4    0    5    2
 15      1     1       4    0    7    6
         2     3       0    5    5    3
         3     3       0    5    4    5
         4     4       0    5    3    2
         5     4       3    0    4    2
 16      1     1       2    0    9   10
         2     3       0   10    9    8
         3     4       0   10    8    7
         4     6       0   10    8    5
         5     9       1    0    8    2
 17      1     7       0    8    8    8
         2     8       7    0    8    8
         3     9       6    0    8    6
         4     9       0    7    8    6
         5    10       0    7    6    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    8    7  110  112
************************************************************************
