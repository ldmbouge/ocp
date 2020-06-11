************************************************************************
file with basedata            : cn118_.bas
initial value random generator: 25011
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  18
horizon                       :  121
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  1   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     16      0       20        7       20
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           5
   3        3          2           6   8
   4        3          3           7   8  11
   5        3          2          10  12
   6        3          2          15  17
   7        3          3           9  10  12
   8        3          3          10  13  14
   9        3          2          13  14
  10        3          2          15  17
  11        3          3          12  14  17
  12        3          1          13
  13        3          2          15  16
  14        3          1          16
  15        3          1          18
  16        3          1          18
  17        3          1          18
  18        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1
------------------------------------------------------------------------
  1      1     0       0    0    0
  2      1     1       0    5    8
         2     7       7    0    6
         3     9       0    1    5
  3      1     2       9    0   10
         2     3       0    5    0
         3     7       0    4    7
  4      1     2       7    0    9
         2     4       0    3    7
         3     6       5    0    0
  5      1     8       3    0    2
         2     8       0    6    0
         3     9       0    5    0
  6      1     1       3    0    5
         2     2       0    6    0
         3     5       0    3    0
  7      1     2       0    2    0
         2     5       6    0    4
         3     6       3    0    3
  8      1     2       0    9    0
         2     3       0    8    0
         3     4       5    0    0
  9      1     5       0    6    0
         2     6       8    0    0
         3    10       0    4    0
 10      1     5       5    0    0
         2     6       0    6    0
         3     7       0    5    0
 11      1     2       0    3    7
         2     2       9    0    0
         3    10       8    0    0
 12      1     1       9    0    7
         2     5       0    7    6
         3     8       0    5    0
 13      1     6       5    0    0
         2     7       0   10    7
         3    10       0    7    6
 14      1     3       6    0    1
         2     3       0    7    0
         3     6       0    3    0
 15      1     3       0    9    0
         2     7       8    0    3
         3     8       0    8    2
 16      1     4       0    6    0
         2     9       0    4    8
         3    10       0    3    6
 17      1     4       7    0    6
         2     6       6    0    4
         3     6       5    0    5
 18      1     0       0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1
   18   15   60
************************************************************************
