************************************************************************
file with basedata            : cn135_.bas
initial value random generator: 1542093638
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  125
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       18        3       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           8  16  17
   3        3          3           5   9  13
   4        3          3           6   7  14
   5        3          3          11  14  15
   6        3          3           8  11  13
   7        3          3           8  10  12
   8        3          1          15
   9        3          2          14  16
  10        3          1          11
  11        3          1          16
  12        3          2          13  15
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
  2      1     4       4    0    6
         2     8       3    0    6
         3    10       2    0    3
  3      1     7       0    8    8
         2     7       7    0    8
         3     9       2    0    8
  4      1     2       7    0    9
         2     4       5    0    5
         3    10       0    3    2
  5      1     2       0    8    8
         2     3       5    0    7
         3     5       0    8    4
  6      1     1       0    6    8
         2     6       8    0    6
         3     6       5    0    7
  7      1     6       0    5    6
         2     7       9    0    3
         3     8       0    3    2
  8      1     7       8    0    5
         2     9       8    0    4
         3     9       6    0    5
  9      1     2       0    9    9
         2     7      10    0    9
         3     9       0    5    9
 10      1     4       9    0    6
         2     9       0    5    4
         3     9       9    0    3
 11      1     2       5    0    7
         2     3       5    0    6
         3     7       5    0    2
 12      1     3       7    0    7
         2     5       0    9    7
         3     8       5    0    3
 13      1     5       5    0    5
         2     5       4    0    6
         3     5       0    6    6
 14      1     2       0    5    4
         2     5       6    0    3
         3     7       5    0    2
 15      1     3       0    7    4
         2     3       9    0    3
         3     3       0    8    2
 16      1     3       9    0    9
         2     9       0    3    7
         3    10       6    0    4
 17      1     2       0   10    6
         2     7       0    9    5
         3    10       0    9    4
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   31   17   74
************************************************************************
