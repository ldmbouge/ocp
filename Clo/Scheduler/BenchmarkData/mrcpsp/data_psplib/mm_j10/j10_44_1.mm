************************************************************************
file with basedata            : mm44_.bas
initial value random generator: 27364
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  12
horizon                       :  89
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     10      0       17        3       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          1           7
   3        3          2           5   7
   4        3          1           5
   5        3          3           6   8   9
   6        3          1          10
   7        3          2           8   9
   8        3          2          10  11
   9        3          1          12
  10        3          1          12
  11        3          1          12
  12        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       9    9    0    8
         2     5       8    9    0    3
         3    10       8    9    8    0
  3      1     1      10    7    8    0
         2     4       5    6    0    8
         3     6       3    5    0    4
  4      1     4       9    7    9    0
         2     7       9    7    0    4
         3     8       8    5    0    2
  5      1     1       7    4    5    0
         2     1       9    3    0    9
         3     9       4    3    0    7
  6      1     5       6    8    9    0
         2     6       6    6    0    2
         3     9       4    3    0    2
  7      1     4       5    9    3    0
         2     5       4    9    3    0
         3     9       3    8    2    0
  8      1     8       7    9    0    5
         2     8       7   10    9    0
         3     9       5    6    0    5
  9      1     5       3    3    0    8
         2     6       3    2    3    0
         3     9       3    2    2    0
 10      1     2       8    4    8    0
         2     6       6    4    0    5
         3    10       3    3    0    5
 11      1     2       9    8    0    3
         2     9       8    5    0    3
         3    10       7    4    0    3
 12      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   16   62   52
************************************************************************
