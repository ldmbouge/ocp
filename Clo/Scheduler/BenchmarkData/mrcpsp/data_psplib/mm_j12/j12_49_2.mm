************************************************************************
file with basedata            : md113_.bas
initial value random generator: 2100351552
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  86
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       12        2       12
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           7   9
   3        3          2           5   6
   4        3          3           5   6   9
   5        3          2           7  10
   6        3          3          11  12  13
   7        3          2           8  13
   8        3          2          11  12
   9        3          2          10  13
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
  2      1     3       0    7    4   10
         2     7       6    0    3   10
         3     7       0    3    2   10
  3      1     1       0    8    8    4
         2     3       9    0    6    3
         3     4       1    0    3    3
  4      1     2       0    8    3    8
         2     4       7    0    2    5
         3     5       0    7    2    5
  5      1     3       4    0    8    6
         2     4       0    5    4    5
         3     4       0   10    3    5
  6      1     8       6    0    5    5
         2     8       0    2    8    3
         3     8       0    1    9    3
  7      1     3       0    8    5    8
         2     4       5    0    5    8
         3     8       0    4    4    7
  8      1     1       0    8    7    7
         2     6       0    2    6    2
         3     6       0    6    5    4
  9      1     2       0    5    6    3
         2     3      10    0    6    3
         3    10       9    0    5    3
 10      1     1       6    0   10    8
         2     6       0    7    9    8
         3     8       6    0    9    5
 11      1     1       6    0    8    4
         2     3       0    3    8    2
         3     7       3    0    8    2
 12      1     2       0   10    9    7
         2     6       0    8    8    5
         3    10       0    6    3    5
 13      1     1       3    0    9    6
         2     7       0    5    7    6
         3     9       2    0    7    4
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    6   10   79   71
************************************************************************
