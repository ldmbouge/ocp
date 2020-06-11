************************************************************************
file with basedata            : cn349_.bas
initial value random generator: 98537903
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  130
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  3   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       15       15       15
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           9  15
   3        3          3           5   6   7
   4        3          2           7   8
   5        3          3           9  10  14
   6        3          2           8  16
   7        3          2          10  11
   8        3          3          10  13  14
   9        3          1          16
  10        3          1          17
  11        3          3          12  13  16
  12        3          1          14
  13        3          2          15  17
  14        3          2          15  17
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2  N 3
------------------------------------------------------------------------
  1      1     0       0    0    0    0    0
  2      1     4       6    0    1    5    3
         2     7       5    0    1    5    2
         3    10       5    0    1    4    2
  3      1     1      10    0    6   10    6
         2     3       9    0    5    9    5
         3     7       0    3    4    9    1
  4      1     2       0    6    2    7    2
         2     3       7    0    2    7    1
         3    10       0    6    1    6    1
  5      1     5       0   10    5    9    5
         2    10       0    8    5    7    5
         3    10      10    0    5    6    1
  6      1     1       0    7    8    8    6
         2     8       0    6    6    7    5
         3    10       3    0    5    4    5
  7      1     3       2    0   10    7    8
         2     3       0    7   10    8    7
         3     8       0    7    7    5    6
  8      1     6       0    9    2    4    8
         2     7       0    9    2    3    1
         3     7       0    8    2    4    1
  9      1     1       4    0    9    4    5
         2     4       4    0    6    4    5
         3     9       0    6    3    2    4
 10      1     5       0    5    8    4    7
         2     8      10    0    5    3    5
         3     8      10    0    2    4    7
 11      1     2       4    0    5    7    2
         2     2       7    0    4    9    2
         3     5       0    7    4    1    1
 12      1     3       7    0    7    9    2
         2     3       0    6    7    8    2
         3     8       7    0    5    5    1
 13      1     1       9    0    9    2   10
         2     4       6    0    9    2    9
         3     6       6    0    6    2    8
 14      1     1       2    0    8    8    1
         2     4       0    6    6    7    1
         3     7       2    0    5    7    1
 15      1     1       0    6    7    8    6
         2     7       0    4    7    8    6
         3     9       0    4    4    8    5
 16      1     1       0    4    7    9   10
         2     7       0    2    6    7    8
         3     8       0    2    4    4    8
 17      1     2       0    1    7    8    8
         2     3      10    0    5    8    7
         3     8      10    0    1    8    6
 18      1     0       0    0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2  N 3
   11   13   91  103   81
************************************************************************
