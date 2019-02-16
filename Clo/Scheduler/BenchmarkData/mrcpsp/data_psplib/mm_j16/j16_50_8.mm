************************************************************************
file with basedata            : md242_.bas
initial value random generator: 139746682
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  137
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       19       10       19
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           5   8  13
   3        3          3           6   9  16
   4        3          3           6   7   9
   5        3          1          11
   6        3          2          10  14
   7        3          2          14  16
   8        3          3           9  10  11
   9        3          1          17
  10        3          2          12  15
  11        3          3          12  14  15
  12        3          1          17
  13        3          2          15  16
  14        3          1          17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     8       0    3   10    5
         2     9       8    0   10    4
         3     9       6    0   10    5
  3      1     6       0    5    5    4
         2     8      10    0    4    4
         3    10       0    5    4    3
  4      1     5       0   10    8    5
         2     6       9    0    5    5
         3    10       0    6    2    4
  5      1     8       3    0    6   10
         2     9       0    9    6   10
         3    10       0    8    3   10
  6      1     4       0    7    5    9
         2     4       9    0    6   10
         3    10       0    8    3    4
  7      1     1       0    5    8    5
         2     3       0    5    8    4
         3     9       0    4    7    4
  8      1     1       0    8    8    8
         2     1       0    7    9    7
         3     4       4    0    7    7
  9      1     1       4    0    7    8
         2     7       0    8    5    8
         3     8       4    0    4    8
 10      1     1       0    2    7    6
         2     4       8    0    6    4
         3     6       5    0    5    4
 11      1     1       0    5    2   10
         2     4       4    0    2   10
         3    10       0    1    1    9
 12      1     1       9    0    8    9
         2     8       0    6    8    4
         3    10       4    0    8    3
 13      1     1       0    5    7    6
         2     2       4    0    6    3
         3     8       0    4    6    3
 14      1     1       6    0    2    9
         2     7       0    4    2    8
         3     8       0    4    1    6
 15      1     1       0    5    5    8
         2     6       0    4    4    7
         3     9       0    2    2    7
 16      1     5       2    0    5    3
         2     8       0    8    4    3
         3    10       0    8    2    2
 17      1     1       5    0    6    8
         2     3       0    3    5    7
         3     6       4    0    5    5
 18      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   14   19   93  106
************************************************************************
