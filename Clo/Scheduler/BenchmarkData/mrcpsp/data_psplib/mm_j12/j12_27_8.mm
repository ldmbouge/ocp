************************************************************************
file with basedata            : md91_.bas
initial value random generator: 837203575
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  95
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       18        0       18
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          3           6   7   9
   3        3          2           5  10
   4        3          3           6   9  10
   5        3          3           6   8  12
   6        3          2          11  13
   7        3          2          12  13
   8        3          2           9  11
   9        3          1          13
  10        3          2          11  12
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     1       6    0    0    9
         2     5       0    4    0    7
         3    10       5    0    7    0
  3      1     5       0    6    9    0
         2     6       0    6    0    2
         3     7       4    0    5    0
  4      1     1       0    7    0    4
         2     6       4    0    0    3
         3     8       2    0    0    3
  5      1     1       8    0    3    0
         2     3       0    4    3    0
         3     4       5    0    3    0
  6      1     4       5    0    0    5
         2     7       5    0    9    0
         3     8       4    0    9    0
  7      1     5       8    0    0    9
         2     8       8    0   10    0
         3    10       0   10    2    0
  8      1     6       0    5    5    0
         2     6       8    0    2    0
         3     7       6    0    0    4
  9      1     1       4    0    0    4
         2     6       0   10    0    4
         3     8       0    6    0    4
 10      1     2       0    8    2    0
         2     3       9    0    0    2
         3     3       0    7    0    1
 11      1     1       4    0    0    6
         2     3       0    3   10    0
         3    10       3    0    0    3
 12      1     2       0    7    7    0
         2     9       0    7    6    0
         3    10       9    0    3    0
 13      1     5       0    6    0   10
         2     6       0    5    5    0
         3    10       7    0    5    0
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   18   17   67   55
************************************************************************
