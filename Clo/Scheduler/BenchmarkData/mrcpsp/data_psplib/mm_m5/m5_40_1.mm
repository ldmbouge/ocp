************************************************************************
file with basedata            : cm540_.bas
initial value random generator: 8967
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  137
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        8       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           6   7  15
   3        5          3           5   7   8
   4        5          3           8   9  14
   5        5          3           9  10  14
   6        5          1          16
   7        5          2           9  12
   8        5          2          10  11
   9        5          2          13  17
  10        5          3          15  16  17
  11        5          1          12
  12        5          1          13
  13        5          1          16
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
  2      1     3       7    4    5    4
         2     4       6    3    4    3
         3     4       5    4    4    3
         4     7       4    3    2    2
         5     9       4    2    2    2
  3      1     1       8    6    2   10
         2     1       8    7    2    9
         3     2       7    6    2    8
         4     4       7    3    2    3
         5     9       6    3    2    3
  4      1     3      10    4    9    8
         2     3      10    5    8    9
         3     4       9    2    7    8
         4     4       9    3    6    8
         5     6       9    1    6    8
  5      1     3       5    7    7    8
         2     6       4    6    6    8
         3     7       4    6    6    3
         4     7       4    5    4    4
         5    10       4    5    4    2
  6      1     3       9    6    6    7
         2     5       6    4    5    4
         3     5       5    5    4    4
         4     7       1    2    4    4
         5     7       1    4    3    4
  7      1     2       4    9    6   10
         2     6       4    8    6    8
         3     7       3    7    6    7
         4     8       3    6    5    7
         5    10       2    5    5    5
  8      1     2       4    7    9    7
         2     2       5    7    9    6
         3     4       4    7    9    6
         4     8       3    7    8    3
         5     9       2    5    7    2
  9      1     1       9    4    3    7
         2     2       7    3    2    5
         3     2       6    4    3    6
         4     4       6    3    2    3
         5     9       5    2    2    3
 10      1     1       8    7   10    9
         2     1       9    6    9    9
         3     3       8    6    8    9
         4     7       5    4    7    9
         5     9       5    3    6    8
 11      1     1       5    5   10    9
         2     3       5    4   10    9
         3     5       4    4    9    9
         4     6       4    4    9    8
         5     8       3    2    8    8
 12      1     4       7    7    7    7
         2     7       4    6    4    6
         3     7       6    6    4    5
         4     7       6    7    4    4
         5     9       3    6    3    3
 13      1     2       8    8    3    7
         2     3       7    5    3    7
         3     3       7    7    3    6
         4     7       6    5    2    4
         5     8       5    2    1    3
 14      1     1       7    4    3    3
         2     2       6    4    3    2
         3     3       5    3    3    2
         4     4       5    3    2    2
         5     5       4    3    2    1
 15      1     2       8    8    7    9
         2     2       9    7    7    9
         3     8       8    5    6    8
         4     8       8    3    7    8
         5     9       8    3    2    6
 16      1     6       9    5    5    6
         2     6       6    5    6    6
         3     6       8    6    5    6
         4     8       4    3    5    5
         5    10       4    3    3    4
 17      1     1       6    6    2    9
         2     9       6    4    2    7
         3     9       6    3    1    8
         4     9       6    5    1    7
         5    10       6    3    1    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   32   29   67   81
************************************************************************
