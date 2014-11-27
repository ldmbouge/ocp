************************************************************************
file with basedata            : md84_.bas
initial value random generator: 23600
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  100
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       17        3       17
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           5  12
   3        3          3           7   8  12
   4        3          3           5   6   8
   5        3          1           7
   6        3          3          11  12  13
   7        3          2           9  10
   8        3          2           9  10
   9        3          2          11  13
  10        3          2          11  13
  11        3          1          14
  12        3          1          14
  13        3          1          14
  14        1          0        
************************************************************************
REQUESTS/DURATIONS:
jobnr. mode duration  R 1  R 2  N 1  N 2
------------------------------------------------------------------------
  1      1     0       0    0    0    0
  2      1     3       8    0    0    5
         2     4       5    0    0    1
         3     8       5    0    6    0
  3      1     3       0    9    0    3
         2     8       9    0    6    0
         3    10       8    0    0    3
  4      1     2       7    0    2    0
         2     7       4    0    0    7
         3    10       4    0    2    0
  5      1     5       0    4    3    0
         2     7       9    0    0    5
         3     9       9    0    1    0
  6      1     4       0    6    0    8
         2     6       3    0    0    1
         3     6       0    6    1    0
  7      1     1       0    8    4    0
         2     5       7    0    3    0
         3     6       0    7    1    0
  8      1     2       7    0    0    4
         2     9       7    0    0    3
         3     9       7    0    3    0
  9      1     3       0    3    0   10
         2     3       4    0    6    0
         3     4       3    0    3    0
 10      1     2       0    6    3    0
         2     2       4    0    4    0
         3    10       4    0    0    3
 11      1     2       0    5    7    0
         2     4       0    5    0    6
         3     9       9    0    7    0
 12      1     1       4    0    0    8
         2     4       0    4    7    0
         3    10       4    0    0    4
 13      1     5       0    3    0    7
         2     5       7    0    0    8
         3     9       5    0    8    0
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
   24   15   43   50
************************************************************************
