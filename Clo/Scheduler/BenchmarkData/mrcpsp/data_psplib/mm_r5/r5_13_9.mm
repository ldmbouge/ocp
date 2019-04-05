************************************************************************
file with basedata            : cr513_.bas
initial value random generator: 1622444194
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  118
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20       15       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          3           8  12  16
   4        3          3           7  12  14
   5        3          3          10  11  16
   6        3          3           8  15  16
   7        3          3           9  10  13
   8        3          1          10
   9        3          1          17
  10        3          1          17
  11        3          2          13  14
  12        3          2          13  15
  13        3          1          17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     2       2    9    3    7    5    0    9
         2     4       2    8    3    5    5    0    9
         3     7       2    6    3    2    4    3    0
  3      1     2      10    8    6    6    6    6    0
         2     3       7    7    6    5    3    3    0
         3    10       6    6    5    3    1    0    7
  4      1     3       5    7    8    4    2    5    0
         2     6       3    6    3    4    2    2    0
         3     6       4    4    3    2    2    0    9
  5      1     2       4    8   10    9    6    0    5
         2     4       2    5   10    8    5    8    0
         3     8       1    4    9    6    2    7    0
  6      1     7       6    3    9    8   10    0    8
         2     8       4    2    6    8    9    0    5
         3     9       3    2    4    7    7    9    0
  7      1     3       9    8    5    8    6    0    6
         2     8       7    8    4    7    5    0    6
         3     9       6    8    4    6    4    0    5
  8      1     2       4    5    6   10    6    5    0
         2     7       3    4    5   10    5    4    0
         3     8       2    4    3    9    5    0    4
  9      1     3       4    5    6    7    9    0    3
         2     4       3    4    6    3    7    8    0
         3     5       3    2    5    1    3    6    0
 10      1     2       5    8    7    7    9    9    0
         2     2       5    7    7    8    9    9    0
         3     7       4    2    7    5    6    6    0
 11      1     5       6    3    9    7    3    7    0
         2     8       4    3    9    6    3    7    0
         3     9       4    2    9    5    3    0    1
 12      1     2       7    7    8    5    8    0    6
         2     3       4    6    6    5    7    0    5
         3     3       5    5    8    4    8    0    5
 13      1     5       9    7    9   10    8    0    9
         2     5      10    5    5   10    8   10    0
         3    10       9    2    2   10    7    8    0
 14      1     4      10    4    4    5    8    0    4
         2     4       9    4    5    5    6    0    6
         3     6       9    4    4    5    6    6    0
 15      1     3       5    9   10    3    6    0    5
         2     4       4    8    9    3    5    4    0
         3     6       2    6    9    3    4    3    0
 16      1     1       3    6    9   10    5    0    5
         2     2       2    5    7    7    4    0    5
         3     6       1    4    6    2    2    5    0
 17      1     6       8    4   10    5    7    7    0
         2     7       8    3    8    5    7    0    8
         3     9       7    3    6    5    6    0    6
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   14   13   15   16   13   49   51
************************************************************************
