************************************************************************
file with basedata            : cr348_.bas
initial value random generator: 273241810
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  3   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       21       14       21
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2          14  17
   3        3          2           5  14
   4        3          3           8  10  12
   5        3          3           6   7  11
   6        3          3           9  12  13
   7        3          3           8   9  13
   8        3          1          15
   9        3          2          10  17
  10        3          2          15  16
  11        3          2          12  13
  12        3          1          17
  13        3          1          16
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     5       1    7    6    9    5
         2     7       1    5    4    7    4
         3    10       1    4    4    6    4
  3      1     1       4    6    2    4    9
         2     3       3    5    2    3    6
         3     7       3    3    1    3    4
  4      1     4       7    3    7    5    2
         2     5       6    2    6    5    1
         3     6       2    2    6    4    1
  5      1     4       5    7    3    6    9
         2    10       5    5    1    1    7
         3    10       5    4    2    2    6
  6      1     8       1    5    8    9    6
         2    10       1    4    6    8    3
         3    10       1    4    5    8    5
  7      1     2       6    6    9   10    7
         2     3       5    5    9    9    7
         3     9       5    5    7    9    5
  8      1     1       8    5    5    5    7
         2     7       7    4    2    5    6
         3    10       7    3    1    4    6
  9      1     1       7    5    8    1    5
         2     3       6    4    7    1    5
         3     4       5    3    6    1    5
 10      1     3       9    7    7    7    5
         2     7       9    6    2    7    2
         3     7       8    5    3    4    4
 11      1     3       5    9    9    8    6
         2     7       4    8    8    8    4
         3    10       3    7    8    4    4
 12      1     2      10    6    4    4    9
         2     4      10    5    3    4    9
         3    10       9    5    3    3    8
 13      1     2       5    3    7    7   10
         2     7       3    3    5    3    9
         3     7       5    2    3    3    8
 14      1     4       5    8    9   10   10
         2     5       4    7    8    8    9
         3     9       4    5    8    6    9
 15      1     4       5    9    6   10    5
         2     5       2    8    6    9    4
         3    10       2    8    4    9    3
 16      1     3       7    9    7    5    3
         2     6       5    4    6    4    3
         3     6       6    4    2    4    3
 17      1     2       7    2    9    5    5
         2     5       7    2    8    3    3
         3     8       6    1    7    3    1
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  N 1  N 2
   24   28   35   89   88
************************************************************************
