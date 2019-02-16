************************************************************************
file with basedata            : cn132_.bas
initial value random generator: 1010229453
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  129
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        5       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   8   9
   3        3          2           5  12
   4        3          3           6   9  15
   5        3          2           7  10
   6        3          3           8  11  13
   7        3          3          15  16  17
   8        3          2          16  17
   9        3          2          12  13
  10        3          2          13  15
  11        3          2          12  14
  12        3          1          16
  13        3          1          14
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
  2      1     5       9    8    0
         2     6       7    8    0
         3    10       6    6    0
  3      1     1       8    8    0
         2     4       6    7    0
         3     5       2    5    8
  4      1     2       9    8   10
         2     5       8    8    8
         3     6       7    8    0
  5      1     1       6    9    5
         2     6       6    7    4
         3     7       5    3    0
  6      1     2       6    8    8
         2     8       5    8    8
         3    10       5    8    0
  7      1     6       9   10    3
         2     7       7    6    0
         3     8       5    5    2
  8      1     3       5    7    4
         2     8       4    4    3
         3     8       3    6    0
  9      1     4       8    7    0
         2     5       6    6    5
         3     8       4    3    0
 10      1     2       6    5    0
         2     3       3    5    9
         3     5       3    4    6
 11      1     1       3   10    0
         2     4       2    6    0
         3     8       1    4    4
 12      1     6       5    6    7
         2     6       3    6    9
         3     7       3    4    7
 13      1     1       4    8    9
         2     7       3    7    0
         3    10       3    6    9
 14      1     4       2   10    0
         2     8       2    9    0
         3    10       1    8    0
 15      1     5       7   10    9
         2     7       6    7    0
         3    10       6    4    0
 16      1     2       9    4    0
         2     3       7    4    0
         3     7       6    2    0
 17      1     8       3    6    7
         2     9       3    5    7
         3    10       3    3    7
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   26   26   90
************************************************************************
