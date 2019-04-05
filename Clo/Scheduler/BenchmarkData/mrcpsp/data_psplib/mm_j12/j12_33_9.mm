************************************************************************
file with basedata            : md97_.bas
initial value random generator: 481222464
************************************************************************
projects                      :  1
jobs (incl. supersource/sink ):  14
horizon                       :  93
RESOURCES
  - renewable                 :  2   R
  - nonrenewable              :  2   N
  - doubly constrained        :  0   D
************************************************************************
PROJECT INFORMATION:
pronr.  #jobs rel.date duedate tardcost  MPM-Time
    1     12      0       11       11       11
************************************************************************
PRECEDENCE RELATIONS:
jobnr.    #modes  #successors   successors
   1        1          3           2   3   4
   2        3          2           8  10
   3        3          3           5   7  10
   4        3          2           6  13
   5        3          3           8   9  13
   6        3          2           7  10
   7        3          2           8   9
   8        3          2          11  12
   9        3          2          11  12
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
  2      1     3       3    0    8    7
         2     5       0    7    5    7
         3     8       2    0    5    5
  3      1     3       0    5    8    8
         2     4       0    4    6    8
         3     5       8    0    5    5
  4      1     2       5    0    9    2
         2     3       4    0    8    2
         3     4       0    6    4    1
  5      1     3       0    8    6    6
         2     4       0    8    5    4
         3     9       0    7    5    4
  6      1     1       1    0    8   10
         2     6       0    5    4   10
         3     8       0    3    2   10
  7      1     3       2    0    8    8
         2     6       0    9    8    1
         3     6       2    0    8    4
  8      1     3       3    0    8    2
         2     3       0    3    8    2
         3     8       3    0    8    1
  9      1     1       8    0   10    6
         2     5       4    0    9    5
         3     9       3    0    9    4
 10      1     3       9    0   10    6
         2     4       7    0    9    6
         3     8       0    7    8    4
 11      1     2       9    0    3    8
         2     7       2    0    3    8
         3     9       0    5    2    7
 12      1     2       0    6    9    5
         2     4       0    3    4    3
         3    10       6    0    4    2
 13      1     1       8    0    4    8
         2     1       0    6    4    8
         3     9       0    2    2    6
 14      1     0       0    0    0    0
************************************************************************
RESOURCEAVAILABILITIES:
  R 1  R 2  N 1  N 2
    7   11   69   57
************************************************************************
