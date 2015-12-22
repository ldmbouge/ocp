************************************************************************
file with basedata            : md247_.bas
initial value random generator: 265008061
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  141
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        5       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   9  11
   3        3          3           5   6  14
   4        3          1          11
   5        3          3           7   8  10
   6        3          3           7   8  17
   7        3          1          12
   8        3          2          12  16
   9        3          3          13  14  15
  10        3          3          11  12  17
  11        3          1          15
  12        3          1          15
  13        3          2          16  17
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       4    6    9    4
         2     4       4    6    9    3
         3    10       4    5    8    3
  3      1     2       5    7   10    6
         2     7       5    7    9    4
         3    10       3    7    7    4
  4      1     2       8    6    9    9
         2     5       6    6    8    7
         3    10       5    3    8    6
  5      1     6       4   10    7   10
         2     8       4   10    5   10
         3     9       3   10    5   10
  6      1     4       6    8    4    8
         2     7       5    8    4    6
         3    10       5    6    4    6
  7      1     3       6    3    4   10
         2     9       6    2    4    9
         3    10       5    1    3    9
  8      1     6       7    8    5    2
         2     8       6    8    3    2
         3    10       2    8    2    1
  9      1     2       5    8    4   10
         2     3       4    6    2    8
         3     9       1    5    1    5
 10      1     1       8    9    5   10
         2     2       7    4    4    4
         3     8       7    3    4    1
 11      1     1       5    7    5    5
         2     3       5    6    4    4
         3    10       4    3    4    3
 12      1     5       6    6    8    6
         2     6       5    6    6    6
         3     7       1    5    3    3
 13      1     7       4    3    7    7
         2     8       4    3    5    2
         3     8       3    2    5    5
 14      1     4       4    7    7    6
         2     4       5    8    6    6
         3    10       3    5    3    6
 15      1     1       8    6    3    2
         2     1       8    8    2    2
         3     9       7    2    2    1
 16      1     1       8    4    9    4
         2     2       7    3    8    4
         3     5       4    3    6    3
 17      1     2       9    8    9    8
         2     5       6    7    6    7
         3     6       3    6    5    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   24   26   96   97
************************************************************************
