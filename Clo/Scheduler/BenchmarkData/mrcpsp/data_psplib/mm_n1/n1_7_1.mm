************************************************************************
file with basedata            : cn17_.bas
initial value random generator: 18847
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  120
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       13       14       13
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   7  12
   3        3          3          10  13  15
   4        3          3           6   8  11
   5        3          2           6  14
   6        3          1           9
   7        3          1          16
   8        3          3           9  14  15
   9        3          2          10  13
  10        3          2          16  17
  11        3          3          12  13  14
  12        3          2          15  16
  13        3          1          17
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     2       8    6    0
         2     6       5    3    0
         3     7       5    1    9
  3      1     3       8    7    3
         2     5       7    6    0
         3     6       5    4    0
  4      1     1       9   10    3
         2     2       8    9    2
         3     3       6    9    2
  5      1     4       4    6   10
         2     7       3    6    9
         3     8       2    6    8
  6      1     1       9    8    0
         2     8       8    8    0
         3    10       6    8   10
  7      1     4       6    8    3
         2     4       6    9    0
         3     5       5    6    0
  8      1     2       9    7    9
         2     5       7    4    0
         3     6       7    3    0
  9      1     1       9    7    0
         2     3       8    6    5
         3     4       7    6    0
 10      1     2       5    7    5
         2     6       4    3    0
         3    10       3    3    5
 11      1     2       8   10    4
         2     5       7    7    0
         3    10       7    6    3
 12      1     1       6    8    9
         2     1       7    7    8
         3     8       1    6    0
 13      1     2       2    6    5
         2     4       2    3    5
         3     9       2    1    4
 14      1     2       9    7    0
         2     2       8    9    0
         3     4       7    4    0
 15      1     5       5    9   10
         2     8       4    9    0
         3    10       4    8    0
 16      1     3       2    3    0
         2     9       2    2    6
         3    10       2    2    0
 17      1     1       9    8    9
         2     6       8    6    0
         3    10       4    5    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   28   32   36
************************************************************************
