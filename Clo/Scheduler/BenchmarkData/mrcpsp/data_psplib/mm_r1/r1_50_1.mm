************************************************************************
file with basedata            : cr150_.bas
initial value random generator: 22685
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  145
RESOURCES
  - renewable                 :  1   R
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
   2        3          3           9  12  13
   3        3          3           5   7  10
   4        3          2           7  13
   5        3          2           6   9
   6        3          3           8  16  17
   7        3          2           8  11
   8        3          1          12
   9        3          3          11  16  17
  10        3          3          11  13  16
  11        3          1          15
  12        3          1          15
  13        3          2          14  17
  14        3          1          15
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       0    8    4
         2     6       4    7    4
         3     9       0    4    4
  3      1     3       8    8    6
         2     5       0    3    6
         3    10       6    2    5
  4      1     1       0    7    5
         2     3       3    6    3
         3     7       0    3    2
  5      1     4       0    8    8
         2     5       8    8    6
         3     7       5    8    3
  6      1     3       0    5    7
         2     4       8    4    6
         3    10       0    4    6
  7      1     2       9    9   10
         2     6       8    9    9
         3    10       6    7    9
  8      1     5       4    6    4
         2     8       1    3    2
         3     8       0    4    2
  9      1     2      10    6    9
         2     5       3    5    7
         3    10       0    3    6
 10      1     1       0    6    4
         2     2       5    4    3
         3     8       0    4    3
 11      1     7       0    6    2
         2     9       0    3    2
         3     9       0    6    1
 12      1     5       9    1    9
         2     6       9    1    8
         3    10       7    1    7
 13      1     3       0    3    9
         2     4       9    3    6
         3    10       8    2    5
 14      1     3       0   10   10
         2     4       0    9    9
         3     7       0    7    7
 15      1     1       0    8    5
         2     2       7    8    4
         3    10       6    7    3
 16      1     3       2    6    9
         2     9       0    3    9
         3    10       0    2    8
 17      1     1       0    7    8
         2     3       4    6    7
         3    10       0    6    4
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  N 1  N 2
   17   95  101
************************************************************************
