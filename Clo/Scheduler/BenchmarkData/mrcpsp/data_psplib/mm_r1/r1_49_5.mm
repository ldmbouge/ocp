************************************************************************
file with basedata            : cr149_.bas
initial value random generator: 195096015
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  126
RESOURCES
  - renewable                 :  1   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       23        4       23
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   8
   3        3          2           7   8
   4        3          3          12  15  17
   5        3          2           7  15
   6        3          3          12  13  14
   7        3          2           9  10
   8        3          3          11  12  14
   9        3          2          11  13
  10        3          2          13  14
  11        3          1          16
  12        3          1          16
  13        3          1          17
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     3       0    8    8
         2     8       3    8    6
         3    10       0    8    6
  3      1     4       0    6    7
         2     7       0    5    6
         3    10       4    5    3
  4      1     4       0    6    5
         2     5       0    5    4
         3     9       0    5    3
  5      1     2       4    6    7
         2     4       3    3    5
         3    10       0    1    3
  6      1     4       4    7    8
         2     4       0    6    9
         3     7       0    2    2
  7      1     7       5    6    4
         2     8       1    3    4
         3     8       2    4    3
  8      1     2       0    7   10
         2     2       0    8    8
         3     5       0    6    6
  9      1     6       5    9    5
         2     6       6    6    5
         3     6       6    8    3
 10      1     2       6    2    9
         2     4       1    2    8
         3     8       0    1    4
 11      1     2       5    7    4
         2     3       4    6    4
         3     7       0    5    4
 12      1     2       2    3    7
         2     3       2    2    6
         3     8       0    2    4
 13      1     1       0    5    8
         2     5       6    3    5
         3     6       4    3    3
 14      1     3       0    8    9
         2     4       4    7    7
         3     7       0    6    4
 15      1     3       0    8    8
         2     3       2    8    6
         3    10       0    6    4
 16      1     3       0    9    9
         2     5       5    9    7
         3     8       3    9    5
 17      1     3       0    9    8
         2     4       0    7    6
         3     7       9    2    6
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
    7   98  104
************************************************************************
