************************************************************************
file with basedata            : c2113_.bas
initial value random generator: 339336815
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19        6       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           7   8  11
   3        3          3           5   6   7
   4        3          3           9  10  15
   5        3          3           9  12  15
   6        3          3           8  10  11
   7        3          3          10  13  14
   8        3          3           9  12  13
   9        3          2          14  17
  10        3          2          16  17
  11        3          2          12  13
  12        3          2          14  17
  13        3          2          15  16
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
  2      1     4       6   10    5    0
         2     8       4   10    0    6
         3     9       1   10    0    2
  3      1     4       8    8    0   10
         2     9       8    4    0    7
         3    10       6    2    0    3
  4      1     4       7    3    4    0
         2     6       7    3    0    7
         3    10       6    2    2    0
  5      1     9       7    7    0    6
         2     9       7    8    9    0
         3    10       7    4    7    0
  6      1     2       3    7    0    6
         2     6       3    7    0    5
         3     7       2    6    3    0
  7      1     1       7    7    0    9
         2     8       7    6    7    0
         3    10       6    3    7    0
  8      1     2       9    9    0    2
         2    10       5    8    8    0
         3    10       6    7    4    0
  9      1     2       4    8    0    2
         2     7       4    8    2    0
         3     9       4    7    0    1
 10      1     7       9    9    7    0
         2     8       8    4    7    0
         3    10       5    4    5    0
 11      1     1       7    8    6    0
         2     1       7    8    0    9
         3     7       3    8    0    8
 12      1     3       6    8    6    0
         2     5       6    8    0    5
         3     6       5    8    6    0
 13      1     1       6    6    7    0
         2     6       5    6    0    5
         3     7       5    5    0    5
 14      1     1       8    8    0   10
         2     2       8    5    8    0
         3     3       7    3    8    0
 15      1     1       9    7    8    0
         2     1      10    8    0    5
         3     2       7    5    0    5
 16      1     2       8    7    7    0
         2     9       7    7    7    0
         3    10       6    4    5    0
 17      1     3       5    4    5    0
         2     6       5    3    0    5
         3    10       1    3    0    3
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   13   16   51   45
************************************************************************
