************************************************************************
file with basedata            : cm531_.bas
initial value random generator: 1843554987
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  148
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       14       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          2           7   8
   3        5          3           5   6  13
   4        5          3          12  13  15
   5        5          3           7  10  11
   6        5          3           7   8  15
   7        5          1           9
   8        5          2           9  11
   9        5          2          12  16
  10        5          3          15  16  17
  11        5          1          12
  12        5          1          14
  13        5          2          16  17
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
  2      1     1       8    2    0    7
         2     3       6    2    0    6
         3     5       6    1    0    6
         4     7       4    1    7    0
         5     7       4    1    0    6
  3      1     1       5    8    0    7
         2     1       6   10    3    0
         3     6       4    7    3    0
         4     8       3    3    3    0
         5     9       1    2    0    7
  4      1     2       5    5   10    0
         2     3       5    4   10    0
         3     4       4    4   10    0
         4     9       4    3    0    4
         5    10       3    2   10    0
  5      1     1       8    8    0    5
         2     3       8    7    8    0
         3     8       7    6    0    4
         4    10       7    5    0    4
         5    10       7    3    5    0
  6      1     2      10    9    0    4
         2     2      10   10    0    3
         3     4       9    8   10    0
         4     5       9    6    0    2
         5    10       8    6    6    0
  7      1     2       5    8    0    5
         2     4       5    7    0    2
         3     5       4    7    5    0
         4     6       4    6    5    0
         5     6       4    7    4    0
  8      1     6       6    6    0    3
         2     6       6    6    4    0
         3     7       4    5    4    0
         4    10       2    4    0    3
         5    10       2    4    3    0
  9      1     3       7   10    9    0
         2     3       7   10    0    9
         3     5       6   10    9    0
         4     9       5    9    0    3
         5    10       4    9    9    0
 10      1     1       9    5    7    0
         2     1       9    5    0    8
         3     7       8    5    6    0
         4     7       7    5    0    6
         5     8       6    4    0    5
 11      1     1       4   10   10    0
         2     4       3    9    8    0
         3     7       2    9    0    6
         4     7       2    9    8    0
         5    10       2    8    0    6
 12      1     4       9    4    0    9
         2     6       9    3    0    7
         3     7       9    3    9    0
         4     8       8    2    0    6
         5     9       8    2    9    0
 13      1     4       8    9    7    0
         2     5       7    9    0    9
         3     6       5    8    0    7
         4     8       4    7    0    6
         5    10       3    7    0    4
 14      1     2       8    6    2    0
         2     3       7    6    0    3
         3     4       5    5    2    0
         4     9       3    5    2    0
         5     9       2    5    0    2
 15      1     2       5    3    0    9
         2     4       5    3    0    6
         3     6       5    2   10    0
         4     8       4    2    6    0
         5    10       4    2    0    1
 16      1     1       7    7    0    6
         2     1       7    7   10    0
         3     4       7    6    0    7
         4     5       7    6   10    0
         5    10       7    5   10    0
 17      1     2       5    6    4    0
         2     3       4    5    0   10
         3     4       4    5    0    9
         4     7       4    4    0    7
         5    10       3    3    0    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   22   22  115  105
************************************************************************
