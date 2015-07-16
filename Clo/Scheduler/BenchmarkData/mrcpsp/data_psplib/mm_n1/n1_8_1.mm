************************************************************************
file with basedata            : cn18_.bas
initial value random generator: 22921
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  116
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       22        3       22
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3          10  11  15
   3        3          3           6   7   8
   4        3          3           5  10  15
   5        3          3           6   9  11
   6        3          2          16  17
   7        3          3           9  12  15
   8        3          3           9  10  11
   9        3          1          13
  10        3          1          14
  11        3          1          12
  12        3          1          13
  13        3          1          14
  14        3          2          16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       6    9    8
         2     2       5    8    0
         3     3       1    8    0
  3      1     5       6    4    2
         2     6       2    1    2
         3     6       3    3    0
  4      1     3       9    4   10
         2     5       7    1    8
         3     5       6    2    0
  5      1     1       4    5    7
         2     2       3    5    0
         3     6       1    4    4
  6      1     6       8    8    2
         2     8       8    6    0
         3    10       7    5    1
  7      1     2       7    4    5
         2     5       6    3    1
         3    10       6    3    0
  8      1     4       7    9   10
         2     7       3    9    0
         3    10       2    8    8
  9      1     5       9    5    5
         2     7       6    3    0
         3     8       4    3    0
 10      1     1       9    8    0
         2     4       7    8    0
         3    10       5    7    8
 11      1     1       4    5    7
         2     5       4    4    6
         3     7       4    1    0
 12      1     4       6    9    7
         2     8       4    8    2
         3    10       2    7    0
 13      1     1      10    6   10
         2     1       9    8    0
         3     2       9    1    0
 14      1     2       6    8    4
         2     5       5    6    0
         3     6       5    5    0
 15      1     2       6    3    7
         2     2       6    4    0
         3     6       4    3    0
 16      1     5      10    9    0
         2     6       5    9    0
         3     9       4    9    8
 17      1     5       4    9    9
         2     7       4    8    0
         3     8       1    8    0
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   30   26   27
************************************************************************
