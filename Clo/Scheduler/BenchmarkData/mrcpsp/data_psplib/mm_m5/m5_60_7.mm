************************************************************************
file with basedata            : cm560_.bas
initial value random generator: 176726534
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  138
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       11       10       11
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        5          3           6   7   9
   3        5          3          11  13  17
   4        5          3           5   6   7
   5        5          1          14
   6        5          2          15  16
   7        5          3           8  10  11
   8        5          2          13  14
   9        5          3          10  13  16
  10        5          2          12  14
  11        5          2          15  16
  12        5          1          17
  13        5          1          15
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
  2      1     2       9    0    9    9
         2     4       9    0    8    8
         3     5       9    0    6    7
         4     9       0    3    4    7
         5    10       8    0    4    5
  3      1     3       9    0    3   10
         2     3       0    9    4   10
         3     5       0    9    3    7
         4     5      10    0    3    7
         5     8       8    0    3    6
  4      1     2       0    5    3    7
         2     3       0    4    3    7
         3     7       7    0    2    7
         4     9       6    0    1    7
         5    10       0    3    1    7
  5      1     4      10    0    7    7
         2     5      10    0    6    7
         3     5       0    4    6    7
         4     6      10    0    5    4
         5     8       0    3    2    4
  6      1     2       7    0    4    7
         2     3       0    9    3    6
         3     8       0    7    3    5
         4    10       0    6    2    3
         5    10       2    0    1    1
  7      1     1       9    0    8    9
         2     1       0    3    7    9
         3     3       9    0    7    9
         4     5       5    0    6    9
         5     6       0    3    4    8
  8      1     2       8    0   10    6
         2     5       0    8    5    4
         3     5       5    0    7    4
         4     6       0    9    4    3
         5     6       3    0    3    3
  9      1     1       3    0    9    4
         2     1       0    9    8    4
         3     2       0    9    8    3
         4     5       0    8    7    3
         5     6       0    7    4    2
 10      1     3       0    7    5    9
         2     5       8    0    4    8
         3     5       0    7    4    8
         4     7       0    7    4    6
         5     9       8    0    2    3
 11      1     3       8    0    9    3
         2     5       0    6    8    3
         3     6       0    4    5    3
         4     8       6    0    4    3
         5    10       5    0    3    3
 12      1     1       5    0    6    8
         2     4       5    0    6    6
         3     5       4    0    6    4
         4     5       0    8    6    6
         5    10       0    2    6    4
 13      1     3       6    0    7    9
         2     8       6    0    3    7
         3     9       0    8    2    4
         4     9       3    0    1    4
         5     9       0    4    2    5
 14      1     1       0   10    7   10
         2     2       0   10    6   10
         3     3       9    0    6   10
         4     4       0    9    6    9
         5     9       0    9    4    9
 15      1     3       0    2    8    7
         2     3       0    2    7    8
         3     6       1    0    7    5
         4     7       0    2    4    4
         5     9       0    1    3    4
 16      1     2       0   10    6    3
         2     4       0    6    5    3
         3     5       0    4    5    3
         4     7       5    0    4    2
         5    10       3    0    4    2
 17      1     1       0    6    7    5
         2     4       0    5    6    5
         3     7       0    4    4    4
         4     7       7    0    5    4
         5     8       6    0    3    4
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   41   36  109  114
************************************************************************
