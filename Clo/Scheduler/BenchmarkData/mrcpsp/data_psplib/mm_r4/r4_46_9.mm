************************************************************************
file with basedata            : cr446_.bas
initial value random generator: 280443769
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  137
RESOURCES
  - renewable                 :  4   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21        6       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           8  17
   3        3          3           5   6  10
   4        3          3           6   9  10
   5        3          2           7   8
   6        3          3          11  15  16
   7        3          3           9  14  16
   8        3          2          13  14
   9        3          2          11  13
  10        3          3          13  16  17
  11        3          1          12
  12        3          1          17
  13        3          1          15
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0
  2      1     4       8    2    2    9    6    5
         2     6       6    2    2    5    4    3
         3     9       3    1    2    4    2    2
  3      1     1       9    4    1   10    8    7
         2     6       9    3    1   10    8    7
         3    10       9    2    1    9    8    6
  4      1     4       5    6    6    7    8    7
         2     7       4    5    6    6    7    6
         3     9       3    4    6    5    7    6
  5      1     1       7    6   10    7    2    8
         2     2       5    5    8    6    2    5
         3    10       5    4    7    4    2    3
  6      1     4       9    2    6    6    3    7
         2     4       9    3    4    7    3   10
         3    10       4    1    2    4    3    7
  7      1     1       8    7    4    7    9    4
         2     5       8    7    3    4    8    4
         3     6       5    7    3    4    4    4
  8      1     2       8   10    3   10    6    9
         2     8       5   10    2    8    6    6
         3    10       1   10    2    8    5    6
  9      1     4       8    7    7    9    6    9
         2     5       7    7    4    9    6    9
         3     6       3    6    1    9    5    9
 10      1     2       4    3   10   10    7    5
         2     5       3    2    8    9    6    5
         3     8       2    1    5    7    4    5
 11      1     7       2   10    4    7    9    7
         2     8       1    9    3    7    8    5
         3    10       1    9    3    4    8    5
 12      1     5       8    6   10    6    5    5
         2     6       7    4    9    6    3    3
         3    10       4    3    9    5    2    2
 13      1     4       3    6    7    7    9    5
         2     5       3    5    6    7    8    5
         3     8       3    5    6    7    5    2
 14      1     3       9    4    8    7    8    6
         2     6       9    3    5    5    8    5
         3     9       9    3    3    2    7    5
 15      1     2       9    8    5    8    9    3
         2     3       8    6    4    8    8    3
         3     9       5    3    2    5    8    3
 16      1     4       7    9    6   10   10    8
         2     5       7    7    3    9    9    6
         3     6       2    6    2    7    6    3
 17      1     1       8    8    5    3    6    3
         2     4       6    7    4    3    5    3
         3     7       4    4    4    2    5    3
 18      1     0       0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  N 1  N 2
   19   20   18   23   96   86
************************************************************************
