************************************************************************
file with basedata            : c2110_.bas
initial value random generator: 1129203839
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  124
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       16        9       16
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   6   7
   3        3          3           5   9  14
   4        3          3           7   9  11
   5        3          1          11
   6        3          3           8  10  11
   7        3          2           8  10
   8        3          3          12  13  14
   9        3          3          10  12  16
  10        3          2          13  15
  11        3          3          12  13  16
  12        3          2          15  17
  13        3          1          17
  14        3          3          15  16  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       0    4    5    0
         2     4       9    0    0    2
         3     5       5    0    4    0
  3      1     4       0    6    0    4
         2    10       0    4    9    0
         3    10       0    5    2    0
  4      1     1       9    0   10    0
         2     5       0    7    9    0
         3     9       8    0    0    7
  5      1     1       0    8    5    0
         2     3       9    0    0    7
         3     4       7    0    0    4
  6      1     2       0    7    0    7
         2     6       0    6    4    0
         3     8       0    4    0    4
  7      1     2       0    3    0    4
         2     7       0    3    0    3
         3     8       0    2    0    3
  8      1     1       1    0    3    0
         2     1       0    8    2    0
         3     5       0    5    0    3
  9      1     3       0   10    8    0
         2     6       2    0    5    0
         3     6       0    8    0    9
 10      1     1       0    4    5    0
         2     3       2    0    2    0
         3     6       0    4    1    0
 11      1     1       0    2    0    5
         2     8       9    0    5    0
         3    10       3    0    0    3
 12      1     5       0    6    0    7
         2     7       0    4    0    6
         3    10       0    3    0    6
 13      1     1      10    0    0    5
         2     4       8    0    9    0
         3     5       0    7    5    0
 14      1     7       3    0    6    0
         2     9       2    0    0    8
         3    10       1    0    5    0
 15      1     2       3    0    5    0
         2     7       0    9    0    4
         3     9       0    8    0    3
 16      1     1       0    9    6    0
         2     7       4    0    6    0
         3    10       0    8    0    6
 17      1     3       0    9    0    9
         2     6       2    0    0    8
         3     9       0    5    0    6
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   10   16   41   51
************************************************************************
