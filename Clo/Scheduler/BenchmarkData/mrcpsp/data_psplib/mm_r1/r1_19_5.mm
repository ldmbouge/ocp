************************************************************************
file with basedata            : cr119_.bas
initial value random generator: 1902019105
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  128
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23       10       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           6
   3        3          2           8  11
   4        3          2           5   8
   5        3          3           6   7  11
   6        3          2           9  14
   7        3          3          13  14  17
   8        3          2          12  14
   9        3          2          10  13
  10        3          1          12
  11        3          3          13  16  17
  12        3          3          15  16  17
  13        3          1          15
  14        3          2          15  16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2      10    6    0
         2     4       0    0    7
         3     9       6    0    4
  3      1     2       0    0    4
         2     8       8    7    0
         3     9       7    7    0
  4      1     3       0    0    3
         2     7       0    0    2
         3     9       8    0    1
  5      1     5       0    0    7
         2     8       0    3    0
         3     8       0    0    5
  6      1     8       8    4    0
         2    10       7    0    6
         3    10       0    3    0
  7      1     4       7    0    5
         2     5       6    0    2
         3     9       0    6    0
  8      1     2       7    0    7
         2     3       0    4    0
         3     9       0    0    3
  9      1     1       6    0    8
         2     6       3    0    5
         3     7       2    0    4
 10      1     1       0    2    0
         2     1       0    0    6
         3     6       4    0    5
 11      1     1       6    9    0
         2     1       0   10    0
         3     5       0    7    0
 12      1     2       7    4    0
         2     9       0    0    7
         3    10       0    0    4
 13      1     2       2    6    0
         2     4       1    0    1
         3     6       1    6    0
 14      1     4       0    0    4
         2     5       0    8    0
         3     8       0    0    3
 15      1     1       5   10    0
         2     1       6    8    0
         3     8       0    0    9
 16      1     3       0   10    0
         2     3       7    7    0
         3     9       6    5    0
 17      1     1       0    0    8
         2     5       6    0    7
         3     6       0   10    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   20   71   63
************************************************************************
