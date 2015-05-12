************************************************************************
file with basedata            : cr110_.bas
initial value random generator: 930353341
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  133
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23       15       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6  11  13
   3        3          3           5   6  14
   4        3          3           6  13  14
   5        3          3           7  12  16
   6        3          1          10
   7        3          2           8  13
   8        3          1           9
   9        3          1          15
  10        3          3          12  15  16
  11        3          3          12  14  16
  12        3          1          17
  13        3          2          15  17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     5       2    0    5
         2     6       0    8    0
         3     7       0    6    0
  3      1     1       0    9    0
         2     2       9    0    2
         3     6       8    7    0
  4      1     3       8    0    6
         2     6       0    3    0
         3     8       0    2    0
  5      1     2       0   10    0
         2     5       0    0    6
         3    10       0    0    5
  6      1     5       2    0    8
         2     7       0    0    4
         3     7       0    4    0
  7      1     3       0    9    0
         2     4       0    8    0
         3     6       0    0    7
  8      1     6       0    2    0
         2     8       0    0    2
         3    10       8    0    1
  9      1     3       0    6    0
         2     8       0    0    6
         3    10       4    0    3
 10      1     5       0    9    0
         2     6       7    3    0
         3    10       6    0    4
 11      1     1       3    0    3
         2     1       0    6    0
         3     8       0    5    0
 12      1     3       3    0   10
         2     8       2    4    0
         3     9       1    4    0
 13      1     4      10    2    0
         2     7       9    0    8
         3     8       8    1    0
 14      1     3       4    4    0
         2     3       7    0    7
         3     8       0    0    6
 15      1     5       5    7    0
         2     8       0    0    8
         3    10       4    4    0
 16      1     3       4    0   10
         2     3       3    6    0
         3     7       0    0    9
 17      1     5       9    0    8
         2     6       0    6    0
         3     9       5    0    6
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   18   48   50
************************************************************************
