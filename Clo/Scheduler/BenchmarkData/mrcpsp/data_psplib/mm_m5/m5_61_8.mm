************************************************************************
file with basedata            : cm561_.bas
initial value random generator: 1047576552
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  136
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
   2        5          3           8  11  12
   3        5          3           5  12  15
   4        5          3           6   7  10
   5        5          1           7
   6        5          2           8  11
   7        5          3           9  13  14
   8        5          2          13  17
   9        5          1          11
  10        5          3          12  14  15
  11        5          1          16
  12        5          2          13  17
  13        5          1          16
  14        5          2          16  17
  15        5          1          18
  16        5          1          18
  17        5          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       5    7    3    7
         2     2       4    5    3    5
         3     2       5    7    2    6
         4     4       4    5    2    4
         5     7       1    2    1    4
  3      1     2       7    7    6    3
         2     4       7    5    4    3
         3     4       7    6    3    3
         4     4       6    4    6    3
         5     7       6    4    1    3
  4      1     1       4    9   10    9
         2     1       5    7   10   10
         3     7       4    5    9    9
         4     8       4    1    9    8
         5     8       4    1    8    9
  5      1     2       5    8    6   10
         2     3       5    7    6    9
         3     9       5    6    5    9
         4     9       4    6    6    9
         5    10       4    5    5    8
  6      1     2       8    8    5    9
         2     4       8    7    5    9
         3     7       7    7    4    8
         4     7       7    6    4    9
         5     9       6    5    3    7
  7      1     3       7    5    8    6
         2     8       7    4    7    3
         3    10       5    4    6    1
         4    10       5    4    4    3
         5    10       4    4    5    3
  8      1     1       8    7    7    4
         2     2       7    6    5    3
         3     2       7    5    7    3
         4     3       4    3    5    3
         5     7       3    3    3    2
  9      1     2       7    3    4    5
         2     4       7    3    3    5
         3     6       6    3    3    4
         4     6       6    2    3    5
         5     9       5    2    2    4
 10      1     2       7    7    7    3
         2     5       6    6    6    3
         3     6       5    4    4    3
         4     6       6    3    5    2
         5     9       5    3    3    2
 11      1     1       3    8    9   10
         2     5       2    8    9    5
         3     5       3    7    8    5
         4     5       2    7    8    6
         5     8       2    6    7    4
 12      1     1       7    8    6    4
         2     2       4    7    6    3
         3    10       4    4    5    1
         4    10       4    4    4    2
         5    10       3    2    5    2
 13      1     1       6    8    8   10
         2     2       5    7    7   10
         3     6       5    6    7   10
         4     9       3    6    6   10
         5    10       2    4    6   10
 14      1     1       8    7    1    3
         2     5       6    7    1    3
         3     7       6    6    1    3
         4     8       5    6    1    2
         5    10       4    6    1    2
 15      1     1       8    8    6    9
         2     2       8    5    3    8
         3     2       8    5    4    7
         4     8       8    4    2    6
         5     8       7    2    3    7
 16      1     3      10   10    9    8
         2     3       9    9   10    7
         3     7       8    6    9    7
         4     7       7    8    8    7
         5     8       6    4    8    7
 17      1     2       6    3    7    7
         2     2       7    3    6    8
         3     2       7    2    7    7
         4     5       4    2    6    6
         5     6       4    1    5    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   12   12  103  109
************************************************************************
