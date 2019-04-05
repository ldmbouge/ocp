************************************************************************
file with basedata            : cr515_.bas
initial value random generator: 488194951
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  143
RESOURCES
  - renewable                 :  5   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       31        3       31
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8  14  16
   3        3          2           5   6
   4        3          3           5   7  14
   5        3          3           8   9  13
   6        3          3           7   8  14
   7        3          2           9  13
   8        3          2          15  17
   9        3          1          10
  10        3          2          11  15
  11        3          1          12
  12        3          2          16  17
  13        3          2          15  16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  R 3  R 4  R 5  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0    0    0
  2      1     2       9    5   10    5    2    7    0
         2     6       9    4    5    3    2    4    0
         3     6       8    3    2    3    1    5    0
  3      1     4       9    4   10    3    7    0    2
         2     5       5    2    7    2    7    0    1
         3     9       1    1    7    1    4    0    1
  4      1     7       4    5    7    6    7    7    0
         2     7       4    5    8    6    5    7    0
         3    10       3    2    3    4    3    0    9
  5      1     7       8    9    6    2    7    2    0
         2     9       8    8    5    2    6    0    6
         3     9       7    8    6    2    6    2    0
  6      1     7       6    6    3    5    9    0   10
         2     8       6    5    3    3    5    0    8
         3    10       5    3    3    3    4    0    7
  7      1     7       5    8    8    6    6    0    3
         2     8       4    7    8    5    5    4    0
         3     9       4    7    5    5    4    0    2
  8      1     4       5    7    9   10    6    3    0
         2     7       5    5    8   10    5    1    0
         3    10       2    4    8   10    4    0    6
  9      1     2      10    6    6    4    8    0    7
         2     7       8    6    3    4    8    0    5
         3    10       8    6    1    3    6    2    0
 10      1     5       7    8    7    2    8    9    0
         2     7       7    8    6    1    7    0    1
         3     9       6    7    6    1    6    8    0
 11      1     1       3    4    2    6    8    0    3
         2     7       3    4    2    3    5    7    0
         3    10       3    3    2    3    2    4    0
 12      1     3       4    9    7    7    2    0    6
         2     8       3    5    6    7    2    7    0
         3     9       3    5    6    6    2    0    4
 13      1     5       7    3    8    6    6    8    0
         2     7       6    3    6    3    4    4    0
         3    10       6    3    4    2    4    0    6
 14      1     6       9    9    5    6    4    0    3
         2     9       9    6    5    4    4    6    0
         3    10       8    6    4    3    4    6    0
 15      1     1      10    8    3    6    3    0   10
         2     9       8    7    3    5    3    4    0
         3    10       7    5    3    5    3    3    0
 16      1     1      10    2   10    4    5    0    6
         2     6      10    2    6    3    5    4    0
         3     6      10    2    4    4    2    0    3
 17      1     2       4    9    5    2    7    8    0
         2     2       3    6    6    2    7    8    0
         3     6       3    5    4    1    1    7    0
 18      1     0       0    0    0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  R 3  R 4  R 5  N 1  N 2
   19   22   23   19   14   45   43
************************************************************************
